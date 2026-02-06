# Hoard::Widgets::QuestLogWidget - Full quest browser panel
#
# Shows categories on the left, quest details on the right.
# Supports browsing, tracking, viewing steps and rewards.
# Toggle visibility with show!/hide!/toggle!.
#
# Usage:
#   class Player < Hoard::Entity
#     script Hoard::Scripts::QuestScript.new
#     widget Hoard::Widgets::QuestLogWidget.new
#   end
#
#   # In a controls script:
#   entity.quest_log_widget.toggle! if args.inputs.keyboard.key_down.j

module Hoard
  module Widgets
    class QuestLogWidget < Widget
      def initialize
        super
        @visible = false
        @selected_category = nil
        @selected_quest = nil
      end

      # Render to the overlay layer so the quest log draws above all other UI
      def _ui_context
        @_ui_ctx ||= Hoard::Ui::Context.new(
          theme: $hoard_ui_theme || Hoard::Ui::Theme.new,
          render_target: :ui_overlay
        )
      end

      def render
        mgr = quest_manager
        return unless mgr

        # Full-screen dim overlay
        $args.outputs[:ui_overlay].primitives << {
          x: 0, y: 0, w: 1280, h: 720, path: :solid,
          r: 0, g: 0, b: 0, a: 180
        }

        panel :quest_log, x: 160, y: 60, w: 960, h: 600, title: "Quest Log  (Score: #{mgr.score})" do
          render_sidebar(mgr)
          render_detail(mgr)
        end
      end

      def on_quest_complete(quest)
        # Could auto-open, flash, etc.
      end

      private

      def render_sidebar(mgr)
        # Category buttons along the top
        cats = mgr.categories
        cat_keys = cats.keys
        cat_keys.each_with_index do |cat_id, i|
          cat = cats[cat_id]
          is_selected = @selected_category == cat_id
          button :"cat_#{cat_id}",
            x: 180 + i * 130, y: 600,
            w: 120, h: 30,
            text: cat[:name],
            style: is_selected ? :primary : :default,
            size: :sm,
            on_click: ->(b) {
              @selected_category = cat_id
              @selected_quest = nil
            }
        end

        # Quest list for selected category
        display_cat = @selected_category || cat_keys.first
        return unless display_cat

        quests = mgr.quests_in_category(display_cat)
          .sort_by { |q| [q.complete? ? 1 : 0, q.active ? 0 : 1, q.index] }

        quests.each_with_index do |q, i|
          is_sel = @selected_quest == q.id
          color_key = if q.complete? then :success
                      elsif !q.active then :text_disabled
                      else is_sel ? :accent : :text_primary
                      end

          status = if q.complete? then "[done]"
                   elsif !q.active then "[locked]"
                   else "#{q.progress_percent}%"
                   end

          button :"ql_#{q.id}",
            x: 180, y: 555 - i * 34,
            w: 260, h: 30,
            text: "#{q.name}  #{status}",
            style: is_sel ? :primary : :ghost,
            size: :sm,
            enabled: q.active,
            on_click: ->(b) { @selected_quest = q.id }
        end
      end

      def render_detail(mgr)
        if @selected_quest
          render_quest_detail(mgr)
        else
          render_overview(mgr)
        end
      end

      def render_overview(mgr)
        label :overview_title,
          x: 520, y: 580,
          text: "Recently Completed",
          size_key: :size_lg,
          color_key: :text_primary

        recent = mgr.recently_completed(5)
        recent.each_with_index do |q, i|
          label :"recent_#{i}",
            x: 520, y: 545 - i * 28,
            text: "#{q.score}pts  #{q.name}",
            size_key: :size_sm,
            color_key: :text_secondary
        end

        if recent.empty?
          label :no_recent,
            x: 520, y: 545,
            text: "No quests completed yet.",
            size_key: :size_sm,
            color_key: :text_disabled
        end
      end

      def render_quest_detail(mgr)
        q = mgr.quest(@selected_quest)
        return unless q

        # Quest name
        label :detail_name,
          x: 520, y: 590,
          text: q.name,
          size_key: :size_lg,
          color_key: :accent

        # Score
        label :detail_score,
          x: 520, y: 560,
          text: "Score: #{q.score}",
          size_key: :size_sm,
          color_key: :warning

        # Track/Untrack button
        button :detail_track,
          x: 750, y: 555,
          w: 100, h: 28,
          text: q.tracking ? "Untrack" : "Track",
          style: q.tracking ? :primary : :default,
          size: :sm,
          on_click: ->(b) { mgr.toggle_tracking(q.id) }

        # Back button
        button :detail_back,
          x: 860, y: 555,
          w: 80, h: 28,
          text: "Back",
          style: :ghost,
          size: :sm,
          on_click: ->(b) { @selected_quest = nil }

        # Description
        label :detail_desc,
          x: 520, y: 530,
          text: q.description,
          size_key: :size_sm,
          color_key: :text_secondary,
          wrap_width: 60

        # Steps
        label :steps_header,
          x: 520, y: 480,
          text: "Steps",
          size_key: :size_md,
          color_key: :text_primary

        q.steps.each_with_index do |step, i|
          icon = if step.complete? then "[x]"
                 elsif !step.active then "[?]"
                 else "[ ]"
                 end

          count_text = step.required > 1 ? " (#{step.completions}/#{step.required})" : ""

          label :"step_#{i}",
            x: 530, y: 450 - i * 24,
            text: "#{icon} #{step.name}#{count_text}",
            size_key: :size_sm,
            color_key: step.complete? ? :success : (step.active ? :text_primary : :text_disabled)
        end

        # Rewards
        if q.has_rewards?
          rewards_y = 450 - q.steps.length * 24 - 20

          label :rewards_header,
            x: 520, y: rewards_y,
            text: "Rewards",
            size_key: :size_md,
            color_key: :text_primary

          q.rewards.each_with_index do |r, i|
            label :"reward_#{i}",
              x: 530, y: rewards_y - 28 - i * 22,
              text: "#{r.name} x#{r.quantity}",
              size_key: :size_sm,
              color_key: :warning
          end

          if q.unclaimed_rewards?
            btn_y = rewards_y - 28 - q.rewards.length * 22 - 10
            button :claim_btn,
              x: 520, y: btn_y,
              w: 140, h: 32,
              text: "Claim Rewards",
              style: :success,
              size: :sm,
              on_click: ->(b) {
                rewards = q.claim_rewards!
                entity.send_to_scripts(:on_claim_rewards, q, rewards)
              }
          end
        end

        # Progress bar
        progress_bar :detail_progress,
          x: 520, y: 100,
          w: 420,
          value: q.progress_percent,
          max: 100,
          label_text: q.complete? ? "Completed" : "Progress",
          color_key: q.complete? ? :success : :accent
      end

      def quest_manager
        return nil unless entity
        qs = entity.respond_to?(:quest_script) ? entity.quest_script : nil
        qs&.manager
      end
    end
  end
end
