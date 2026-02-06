# Hoard::Quests::QuestManager - Tree-based quest registry and state manager
#
# Usage:
#   qm = Hoard::Quests::QuestManager.new
#   qm.define(id: :exploration, name: "Exploration")
#   qm.define(id: :feathers, name: "Feathers", parent: :exploration)
#   qm.define(id: :f1, name: "Feather 1", parent: :feathers, score: 5,
#             steps: [{ id: :find, name: "Find it" }])
#   qm.progress(:f1, :find)

module Hoard
  module Quests
    class QuestManager
      attr_reader :quests, :roots, :on_quest_complete, :on_quest_progress

      def initialize
        @quests = {}            # flat id -> Quest lookup
        @roots = []             # top-level quests (no parent)
        @on_quest_complete = []
        @on_quest_progress = []
        @recently_completed = []
      end

      # ------------------------------------------------------------------
      # Quest definition
      # ------------------------------------------------------------------

      def define(**opts)
        q = Quest.new(**opts)
        @quests[q.id] = q

        if q.parent_id
          parent = @quests[q.parent_id]
          if parent
            parent.children << q
          end
        else
          @roots << q
        end

        q
      end

      def quest(id)
        @quests[id]
      end

      # ------------------------------------------------------------------
      # Quest interaction
      # ------------------------------------------------------------------

      # Progress a step on a leaf quest. Bubbles completion up to parents.
      def progress(quest_id, step_id, count = 1)
        q = @quests[quest_id]
        return false unless q && q.active && q.leaf? && !q.complete?

        step = q.find_step(step_id)
        return false unless step && step.active

        step.complete!(count)

        @on_quest_progress.each { |cb| cb.call(q, step) }

        if q.check_completion!
          @recently_completed.unshift(q)
          @recently_completed = @recently_completed.first(10)
          @on_quest_complete.each { |cb| cb.call(q) }

          # Bubble up: check if parent branches are now complete
          bubble_completion(q)
          return true
        end

        false
      end

      # Complete a leaf quest instantly
      def complete!(quest_id)
        q = @quests[quest_id]
        return false unless q && q.leaf? && !q.complete?

        q.steps.each { |s| s.completions = s.required }
        q.check_completion!

        @recently_completed.unshift(q)
        @recently_completed = @recently_completed.first(10)
        @on_quest_complete.each { |cb| cb.call(q) }

        bubble_completion(q)
        true
      end

      def activate!(quest_id)
        q = @quests[quest_id]
        q.active = true if q
      end

      def deactivate!(quest_id)
        q = @quests[quest_id]
        q.active = false if q
      end

      def toggle_tracking(quest_id)
        q = @quests[quest_id]
        q.tracking = !q.tracking if q
      end

      def track!(quest_id)
        q = @quests[quest_id]
        q.tracking = true if q
      end

      def untrack!(quest_id)
        q = @quests[quest_id]
        q.tracking = false if q
      end

      # ------------------------------------------------------------------
      # Queries
      # ------------------------------------------------------------------

      def tracked_quests
        @quests.values.select { |q| q.tracking && q.active && q.leaf? && !q.complete? }
      end

      def recently_completed(limit = 5)
        @recently_completed.first(limit)
      end

      def score
        @roots.sum { |r| r.total_score }
      end

      # All leaf quests
      def leaf_quests
        @quests.values.select(&:leaf?)
      end

      def completed_leaves
        leaf_quests.select(&:complete?)
      end

      # ------------------------------------------------------------------
      # Callbacks
      # ------------------------------------------------------------------

      def on_complete(&blk)
        @on_quest_complete << blk
      end

      def on_progress(&blk)
        @on_quest_progress << blk
      end

      private

      # Walk up from a completed quest checking if parents are now done
      def bubble_completion(quest)
        parent = quest.parent_id ? @quests[quest.parent_id] : nil
        while parent
          if parent.check_completion!
            @recently_completed.unshift(parent)
            @recently_completed = @recently_completed.first(10)
            @on_quest_complete.each { |cb| cb.call(parent) }
          end
          parent = parent.parent_id ? @quests[parent.parent_id] : nil
        end
      end
    end
  end
end
