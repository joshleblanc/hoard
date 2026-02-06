# Hoard::Widgets::QuestTrackerWidget - HUD overlay showing tracked quests
#
# Displays a compact list of tracked quests with progress percentages.
# Attach to the same entity as QuestScript.
#
# Usage:
#   class Player < Hoard::Entity
#     script Hoard::Scripts::QuestScript.new
#     widget Hoard::Widgets::QuestTrackerWidget.new
#   end

module Hoard
  module Widgets
    class QuestTrackerWidget < Widget
      attr_accessor :anchor_x, :anchor_y

      def initialize
        super
        @anchor_x = 1060  # top-right area
        @anchor_y = 680
      end

      def render
        mgr = quest_manager
        return unless mgr

        tracked = mgr.tracked_quests
        return if tracked.empty?

        panel_h = 30 + tracked.length * 28
        panel :quest_tracker, x: @anchor_x, y: @anchor_y - panel_h, w: 200, h: panel_h, title: "Tracked" do
          tracked.each_with_index do |q, i|
            pct = q.progress_percent
            label :"qt_name_#{i}",
              text: "#{q.name}",
              size_key: :size_xs,
              color_key: pct >= 100 ? :success : :text_primary

            # Inline progress text to the right would need manual positioning;
            # for now, include percentage in the label
            label :"qt_pct_#{i}",
              text: "#{pct}%",
              size_key: :size_xs,
              color_key: :text_secondary
          end
        end
      end

      def on_quest_progress(quest, step)
        # Widget re-renders automatically each frame
      end

      def on_quest_complete(quest)
        # Tracked quests auto-remove when complete
      end

      private

      def quest_manager
        return nil unless entity
        qs = entity.respond_to?(:quest_script) ? entity.quest_script : nil
        qs&.manager
      end
    end
  end
end
