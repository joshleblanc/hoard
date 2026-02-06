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
        @curr.to_f / @limit
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
        progress_bar :progress,
          x: entity_x(-max_w / 2),
          y: entity_y,
          w: max_w,
          value: @curr,
          max: @limit,
          color_key: :accent,
          label_text: done? ? "Done!" : "",
          show_percentage: false
      end
    end
  end
end
