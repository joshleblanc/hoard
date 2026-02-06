# Hoard::Quests::QuestManager - Central registry and state manager for all quests
#
# Attach to an entity via QuestScript, or use standalone.
#
# Usage:
#   qm = Hoard::Quests::QuestManager.new
#   qm.define(id: :slay_slimes, name: "Slay 10 Slimes", score: 5,
#             steps: [{ id: :kill, name: "Kill slimes", required: 10 }])
#   qm.progress(:slay_slimes, :kill)        # +1 completion
#   qm.progress(:slay_slimes, :kill, 5)     # +5 completions
#   qm.quest(:slay_slimes).progress_percent # => 60

module Hoard
  module Quests
    class QuestManager
      attr_reader :quests, :categories, :on_quest_complete, :on_quest_progress

      def initialize
        @quests = {}
        @categories = {}
        @on_quest_complete = []  # array of callables
        @on_quest_progress = []  # array of callables
        @recently_completed = []
      end

      # ------------------------------------------------------------------
      # Quest definition
      # ------------------------------------------------------------------

      # Define a quest. Can be called from scripts, data files, etc.
      def define(**opts)
        q = Quest.new(**opts)
        @quests[q.id] = q

        cat = q.category || :default
        @categories[cat] ||= { name: cat.to_s.capitalize, quests: [] }
        @categories[cat][:quests] << q.id

        q
      end

      # Define a category (optional -- auto-created if not defined)
      def define_category(id, name:)
        @categories[id] ||= { name: name, quests: [] }
        @categories[id][:name] = name
      end

      # ------------------------------------------------------------------
      # Quest interaction
      # ------------------------------------------------------------------

      def quest(id)
        @quests[id]
      end

      # Progress a step within a quest. Returns true if the quest just completed.
      def progress(quest_id, step_id, count = 1)
        q = @quests[quest_id]
        return false unless q && q.active && !q.complete?

        step = q.find_step(step_id)
        return false unless step && step.active

        step.complete!(count)

        @on_quest_progress.each { |cb| cb.call(q, step) }

        if q.check_completion!
          @recently_completed.unshift(q)
          @recently_completed = @recently_completed.first(10)
          @on_quest_complete.each { |cb| cb.call(q) }
          return true
        end

        false
      end

      # Complete an entire quest instantly (all steps)
      def complete!(quest_id)
        q = @quests[quest_id]
        return false unless q && !q.complete?

        q.steps.each { |s| s.completions = s.required }
        q.check_completion!

        @recently_completed.unshift(q)
        @recently_completed = @recently_completed.first(10)
        @on_quest_complete.each { |cb| cb.call(q) }
        true
      end

      # Activate a quest (make it visible/progressable)
      def activate!(quest_id)
        q = @quests[quest_id]
        q.active = true if q
      end

      # Deactivate a quest
      def deactivate!(quest_id)
        q = @quests[quest_id]
        q.active = false if q
      end

      # Toggle tracking
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
        @quests.values.select { |q| q.tracking && q.active && !q.complete? }
      end

      def active_quests
        @quests.values.select { |q| q.active && !q.complete? }
      end

      def completed_quests
        @quests.values.select(&:complete?)
      end

      def recently_completed(limit = 5)
        @recently_completed.first(limit)
      end

      def quests_in_category(category_id)
        ids = @categories.dig(category_id, :quests) || []
        ids.map { |id| @quests[id] }.compact
      end

      def unclaimed_rewards
        @quests.values.select(&:unclaimed_rewards?)
      end

      def score
        completed_quests.sum(&:score)
      end

      def all_quests_sorted
        @quests.values.sort_by { |q| [q.complete? ? 1 : 0, q.active ? 0 : 1, q.index] }
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
    end
  end
end
