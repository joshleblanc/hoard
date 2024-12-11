module Hoard
  module Widgets
    class ProgressBarWidget < Widget
      attr_reader :limit, :curr

      def initialize(limit: 100)
        super()
        @limit = limit
        @curr = 0
        @active = false
        @done = false
        show!
      end

      def progress
        @curr / @limit
      end

      def reset!
        @done = false
        @active = false
        @curr = 0
      end

      def activate!
        @done = false
        @active = true
        @curr = 0
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
        100
      end

      def render
        window(w: max_w * progress, h: 25, x: entity.gx - (max_w / 2), y: entity.gy, background: Ui::Colors::BLUE) do 
          if done? 
            text(key: "result") { "Done!" }
          end
        end
      end
    end
  end
end
