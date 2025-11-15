module Hoard
  module Widgets
    class QuestsWidget < Widget
      def init
        @selected_quest_id = nil
        @selected_parent_id = nil
      end

      def quests_script
        entity.user_quests_script
      end

      def selected_quest
        return nil unless @selected_quest_id
        quests_script&.find_quest(@selected_quest_id)
      end

      def selected_parent
        return nil unless @selected_parent_id
        quests_script&.find_quest(@selected_parent_id)
      end

      def current_quests
        if @selected_parent_id
          selected_parent&.children || []
        else
          quests_script&.quests&.select(&:is_root?) || []
        end
      end

      def handle_quest_click(quest)
        if quest.has_children? && !quest.is_end?
          @selected_parent_id = quest.id
          @selected_quest_id = nil
        else
          @selected_quest_id = quest.id
        end
      end

      def handle_back_click
        if selected_quest
          @selected_quest_id = nil
        elsif selected_parent
          @selected_parent_id = selected_parent.parent_id
        end
      end

      def render
        # window(key: :quests, x: 100, y: 600, w: 1080, h: 520, background: [20, 20, 20, 200], border: [113, 113, 152, 255]) do
        #   button(key: :close, x: 1080, y: 560, w: 30, h: 30, on_click: -> { hide! }) do
        #     text { "X" }
        #   end
        #   row do
        #     # Left column: Quest list
        #     col(w: 300, border_r: 4, border_color: [0, 0, 0, 255]) do
        #       # Header
        #       if selected_parent || selected_quest
        #         button(h: 50, key: :back, on_click: -> { handle_back_click }) do
        #           text(key: :back_text) { "< Back" }
        #         end
        #       else
        #         text(key: :header, h: 50, justify: :center) { "Quests" }
        #       end

        #       # Quest items
        #       current_quests.each do |quest|
        #         button(h: 40, key: "quest-#{quest.id}", on_click: -> { handle_quest_click(quest) }) do
        #           text(key: :lock) { "🔒" } unless quest.is_active?
        #           text(key: :name) { quest.name }
        #         end
        #       end
        #     end

        #     # Right column: Quest details
        #     col(w: 780) do
        #       if selected_quest
        #         col(padding: 10) do
        #           text(key: :selected_name, h: 50, justify: :center) { selected_quest.name }
        #           row(h: 50) do
        #             button(key: :track_button, on_click: -> { selected_quest.toggle_tracking }) do
        #               text { selected_quest.to_h[:tracking] ? "Untrack" : "Track" }
        #             end
        #           end
        #           row do
        #             col(w: 200) do
        #               text(key: :score_label) { "Score:" }
        #               text(key: :score_value) { selected_quest.score.to_s }
        #               text(key: :rewards_label) { "Rewards:" }
        #               row do
        #                 selected_quest.rewards.each_with_index do |reward, i|
        #                   col(key: "reward-#{i}", w: 100) do
        #                     # Placeholder for reward icon
        #                     image(w: 64, h: 64, path: 'sprites/error.png')
        #                     text(key: :reward_count) { "x#{reward.quantity}" }
        #                   end
        #                 end
        #               end
        #             end
        #             col(w: 580) do
        #               text(key: :selected_desc) { selected_quest.description }
        #               if selected_quest.is_end?
        #                 text(key: :steps_label) { "Steps:" }
        #                 selected_quest.children.each do |step|
        #                   row(key: "step-#{step.id}") do
        #                     text(key: :checkbox) { step.is_complete? ? "✅" : "🔲" }
        #                     text(key: :step_name) { step.name }
        #                   end
        #                 end
        #               end
        #             end
        #           end
        #         end
        #       else
        #         col do
        #           text(key: :recently_completed_title, h: 50, justify: :center) { "Recently Completed" }
        #           quests_script&.recently_completed&.each do |quest|
        #             row(key: "recent-#{quest[:id]}", h: 60) do
        #               text(key: :quest_name) { quest[:name] }
        #               text(key: :quest_score) { "+#{quest[:score]}" }
        #             end
        #           end
        #         end
        #       end
        #     end
        #   end
        # end
      end
    end
  end
end
