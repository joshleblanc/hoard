module Hoard
  module Scripts
    class QuestRewardScript < Hoard::Script
      attr_accessor :quest_id, :template, :quantity

      def initialize(quest_id, template, quantity = 1)
        @quest_id = quest_id
        @template = template
        @quantity = quantity
      end

      def name
        # FIXME: Not sure how to get friendly name from template
        template&.name || ""
      end

      def description
        # FIXME: Not sure how to get description from template
        template&.description || ""
      end

      def icon
        # FIXME: Not sure how to get icon from template
        ""
      end

      def to_h
        {
          quest_id: @quest_id,
          template_name: @template&.name,
          name: name,
          count: @quantity,
          description: description,
          icon: icon
        }
      end
    end
  end
end
