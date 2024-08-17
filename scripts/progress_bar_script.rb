module Hoard
  module Scripts
    class ProgressBarScript < Script
      attr_reader :limit, :curr

      def initialize(limit: 100)
        @limit = limit
        @curr = 0
        @active = false
        @done = false
      end

      def progress
        @curr / @limit
      end

      def reset!
        @done = false
        @active = false
      end

      def activate!
        @done = false
        @active = true
      end

      def done?
        progress >= 1 && @active
      end

      def active?
        @active
      end

      def idle?
        !@active
      end

      def update
        return unless @active

        @curr += 1 unless done?
      end

      def max_w
        entity.w * 2
      end

      def post_update
        return unless @active

        if done?
          outputs[:ui].labels << {
            x: Game.s.camera.level_to_global_x(entity.x),
            y: entity.y - 64,
            font_size: 1,
            text: "Done!",
            alignment_enum: 1,
            r: 255, g: 255, b: 255, a: 255,
          }
        else
          outputs[:scene].primitives << {
            x: entity.x - (max_w / 2),
            y: entity.y.from_top + entity.h + 20,
            w: max_w * progress,
            h: 4,
            r: 255, g: 255, b: 255,
            primitive_marker: :solid,
          }
        end
      end
    end
  end
end
