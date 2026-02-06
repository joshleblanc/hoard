# Hoard::Widgets::NotificationWidget - Generic toast notification system
#
# Shows brief themed popups that auto-fade. Any system can push notifications.
#
# Usage:
#   class Player < Hoard::Entity
#     widget Hoard::Widgets::NotificationWidget.new
#   end
#
#   # From anywhere with access to the entity:
#   entity.notification_widget.notify("Item Acquired", "Iron Sword x1", :success)
#   entity.notification_widget.notify("Level Up!", "You reached level 5", :warning)
#   entity.notification_widget.notify("Quest Complete!", quest.name, :accent)

module Hoard
  module Widgets
    class NotificationWidget < Widget
      DISPLAY_DURATION = 240   # frames (~4 seconds at 60fps)
      FADE_DURATION    = 60    # frames to fade out
      MAX_VISIBLE      = 3

      def initialize
        super
        @notifications = []
      end

      # Push a notification. This is the public API -- call from anywhere.
      #   text:      bold top line ("Item Acquired", "Quest Complete!", etc.)
      #   subtext:   detail line ("Iron Sword x1", quest name, etc.)
      #   color_key: theme color for the accent bar (:success, :accent, :warning, :error)
      def notify(text, subtext = "", color_key = :accent)
        @notifications.unshift({
          text: text,
          subtext: subtext,
          color_key: color_key,
          started_at: Kernel.tick_count
        })
        @notifications = @notifications.first(MAX_VISIBLE)
      end

      # --- Quest integration (called automatically by send_to_widgets) ---

      def on_quest_complete(quest)
        notify("Quest Complete!", quest.name, :success)
      end

      def on_quest_progress(quest, step)
        return if quest.complete?
        if step.complete? && quest.steps.length > 1
          notify("Step Complete", "#{quest.name}: #{step.name}", :accent)
        end
      end

      def render
        return if @notifications.empty?

        now = Kernel.tick_count
        t = $hoard_ui_theme || Hoard::Ui::Theme.new

        @notifications.reject! { |n| now - n[:started_at] > DISPLAY_DURATION + FADE_DURATION }

        @notifications.each_with_index do |n, i|
          elapsed = now - n[:started_at]
          next if elapsed < 0

          alpha = if elapsed > DISPLAY_DURATION
                    fade_progress = (elapsed - DISPLAY_DURATION).to_f / FADE_DURATION
                    (255 * (1.0 - fade_progress)).to_i.clamp(0, 255)
                  else
                    255
                  end

          next if alpha <= 0

          nx = 640
          ny = 640 - i * 60

          bg = t.colors[:bg_secondary]
          $args.outputs[:ui].primitives << {
            x: nx - 180, y: ny - 20, w: 360, h: 50, path: :solid,
            r: bg[:r], g: bg[:g], b: bg[:b], a: (alpha * 0.9).to_i
          }

          bc = t.colors[n[:color_key]] || t.colors[:accent]
          $args.outputs[:ui].primitives << {
            x: nx - 180, y: ny - 20, w: 360, h: 50,
            r: bc[:r], g: bc[:g], b: bc[:b], a: alpha,
            primitive_marker: :border
          }

          $args.outputs[:ui].primitives << {
            x: nx - 180, y: ny - 20, w: 4, h: 50, path: :solid,
            r: bc[:r], g: bc[:g], b: bc[:b], a: alpha
          }

          tc = t.colors[:text_primary]
          $args.outputs[:ui].primitives << {
            x: nx, y: ny + 18, text: n[:text],
            size_px: 20, anchor_x: 0.5, anchor_y: 0.5,
            r: tc[:r], g: tc[:g], b: tc[:b], a: alpha
          }

          sc = t.colors[:text_secondary]
          $args.outputs[:ui].primitives << {
            x: nx, y: ny - 4, text: n[:subtext],
            size_px: 16, anchor_x: 0.5, anchor_y: 0.5,
            r: sc[:r], g: sc[:g], b: sc[:b], a: alpha
          }
        end
      end
    end
  end
end
