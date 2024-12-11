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

      def init 
        @widget = entity.progress_bar_widget
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

      end
    end
  end
end
