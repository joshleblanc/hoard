# Hoard::Quests::Quest - Tree-based quest/achievement node
#
# Quests form an infinitely nestable tree. A quest with children is a
# branch (category/group). A quest with no children but with steps is
# a leaf (completable quest). Progress rolls up from leaves to parents.
#
# Usage:
#   qm = Hoard::Quests::QuestManager.new
#
#   qm.define(id: :exploration, name: "Exploration")
#   qm.define(id: :hidden,     name: "Hidden Items",  parent: :exploration)
#   qm.define(id: :feathers,   name: "Feathers",      parent: :hidden)
#   qm.define(id: :feather_1,  name: "Feather 1",     parent: :feathers,
#             steps: [{ id: :find, name: "Find the feather" }], score: 5)
#   qm.define(id: :feather_2,  name: "Feather 2",     parent: :feathers,
#             steps: [{ id: :find, name: "Find the feather" }], score: 5)

module Hoard
  module Quests
    class Quest
      attr_accessor :id, :name, :description, :parent_id,
                    :score, :active, :tracking,
                    :steps, :rewards, :completed, :completed_at,
                    :claimed_rewards, :index, :children, :expanded

      def initialize(id:, name:, description: "", parent: nil,
                     score: 0, active: true, tracking: false,
                     steps: [], rewards: [], index: 0)
        @id = id
        @name = name
        @description = description
        @parent_id = parent
        @score = score
        @active = active
        @tracking = tracking
        @index = index
        @expanded = false
        @children = []

        @steps = steps.map.with_index do |s, i|
          Step.new(
            id: s[:id] || :"step_#{i}",
            name: s[:name] || "Step #{i + 1}",
            description: s[:description] || "",
            required: s[:required] || 1,
            active: s.fetch(:active, true),
            index: i
          )
        end

        @rewards = rewards.map do |r|
          Reward.new(
            name: r[:name],
            quantity: r[:quantity] || 1,
            description: r[:description] || ""
          )
        end

        @completed = false
        @completed_at = nil
        @claimed_rewards = false
      end

      # A leaf quest has steps and no children. A branch has children.
      def leaf?
        @children.empty?
      end

      def branch?
        !@children.empty?
      end

      # Progress for a leaf is step-based. For a branch, it's the average
      # of children's progress (recursive).
      def progress
        return 1.0 if @completed
        if leaf?
          return 0.0 if @steps.empty?
          @steps.sum { |s| s.progress } / @steps.length.to_f
        else
          active_children = @children.select(&:active)
          return 0.0 if active_children.empty?
          active_children.sum { |c| c.progress } / active_children.length.to_f
        end
      end

      def progress_percent
        (progress * 100).to_i
      end

      def complete?
        @completed
      end

      # For leaves: all steps done. For branches: all children complete.
      def done?
        if leaf?
          @steps.all?(&:complete?)
        else
          @children.all? { |c| !c.active || c.complete? }
        end
      end

      def check_completion!
        if !@completed && done?
          @completed = true
          @completed_at = Kernel.tick_count
          return true
        end
        false
      end

      # Total score for this node and all descendants
      def total_score
        if leaf?
          @completed ? @score : 0
        else
          own = @completed ? @score : 0
          own + @children.sum { |c| c.total_score }
        end
      end

      def has_rewards?
        !@rewards.empty?
      end

      def unclaimed_rewards?
        @completed && has_rewards? && !@claimed_rewards
      end

      def claim_rewards!
        @claimed_rewards = true
        @rewards
      end

      def find_step(step_id)
        @steps.find { |s| s.id == step_id }
      end

      # Count of completed leaves under this node (recursive)
      def completed_count
        if leaf?
          @completed ? 1 : 0
        else
          @children.sum { |c| c.completed_count }
        end
      end

      # Count of total leaves under this node (recursive)
      def total_count
        if leaf?
          1
        else
          @children.sum { |c| c.total_count }
        end
      end
    end

    # A single step within a leaf quest
    class Step
      attr_accessor :id, :name, :description, :required, :completions,
                    :active, :index

      def initialize(id:, name:, description: "", required: 1, active: true, index: 0)
        @id = id
        @name = name
        @description = description
        @required = required
        @completions = 0
        @active = active
        @index = index
      end

      def progress
        return 1.0 if complete?
        @completions.to_f / @required
      end

      def complete?
        @completions >= @required
      end

      def complete!(count = 1)
        @completions = [@completions + count, @required].min
      end
    end

    # A reward granted on quest completion
    class Reward
      attr_accessor :name, :quantity, :description

      def initialize(name:, quantity: 1, description: "")
        @name = name
        @quantity = quantity
        @description = description
      end
    end
  end
end
