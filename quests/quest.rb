# Hoard::Quests::Quest - Data model for a single quest/achievement
#
# Quests form a tree. A "category" quest (is_end: false) groups child quests.
# A "leaf" quest (is_end: true) has steps that can be completed.
#
# Usage:
#   quest = Hoard::Quests::Quest.new(
#     id: :find_treasure,
#     name: "Find Sunken Treasure",
#     description: "Rumour has it there's treasure under the Lurten Docks",
#     category: :exploration,
#     score: 10,
#     steps: [
#       { id: :dive, name: "Dive into the water" },
#       { id: :find_chest, name: "Find the chest" },
#       { id: :collect_gems, name: "Collect gems", required: 5 },
#     ],
#     rewards: [
#       { name: "Gold", quantity: 100 },
#       { name: "Diving Helmet", quantity: 1 },
#     ]
#   )

module Hoard
  module Quests
    class Quest
      attr_accessor :id, :name, :description, :category, :parent_id,
                    :score, :is_end, :active, :tracking,
                    :steps, :rewards, :completed, :completed_at,
                    :claimed_rewards, :index

      def initialize(id:, name:, description: "", category: nil, parent_id: nil,
                     score: 0, is_end: true, active: true, tracking: false,
                     steps: [], rewards: [], index: 0)
        @id = id
        @name = name
        @description = description
        @category = category
        @parent_id = parent_id
        @score = score
        @is_end = is_end
        @active = active
        @tracking = tracking
        @index = index

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

      def progress
        return 1.0 if @completed
        return 0.0 if @steps.empty?
        @steps.sum { |s| s.progress } / @steps.length.to_f
      end

      def progress_percent
        (progress * 100).to_i
      end

      def complete?
        @completed
      end

      def done?
        @steps.all?(&:complete?)
      end

      def check_completion!
        if !@completed && done?
          @completed = true
          @completed_at = Kernel.tick_count
          return true
        end
        false
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

      def to_h
        {
          id: @id, name: @name, description: @description,
          category: @category, parent_id: @parent_id,
          score: @score, is_end: @is_end, active: @active,
          tracking: @tracking, completed: @completed,
          completed_at: @completed_at, progress: progress_percent,
          steps: @steps.map(&:to_h),
          rewards: @rewards.map(&:to_h)
        }
      end
    end

    # A single step within a quest
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

      def to_h
        {
          id: @id, name: @name, description: @description,
          required: @required, completions: @completions,
          active: @active, done: complete?
        }
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

      def to_h
        { name: @name, quantity: @quantity, description: @description }
      end
    end
  end
end
