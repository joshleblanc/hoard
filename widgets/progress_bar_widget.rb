module Hoard
  module Widgets
    class ProgressBarWidget < Widget
      attr_reader :limit, :curr

      def initialize(limit: 100)
        super(rows: 2, cols: 4, row: 0, col: 0)

        @limit = limit
        @curr = 0
        @active = true
        @done = false
        show!
      end

      def init
        @row = grid_y(entity.y.from_top) #- grid_y(entity.h)
        @col = grid_x(entity.x)
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

      def render
        # outputs[:scene].borders << {
        #   w: 1280,
        #   h: 720,
        #   r: 255, g: 0, b: 0, a: 255,

        # }
        # bordered_container!

        # if done?
        #   text! wrap_layout(container, rect(row: 0, col: 0, w: 4, h: 1)), "Done!"
        #   # outputs[:ui].labels << {
        #   #   x: Game.s.camera.level_to_global_x(entity.x),
        #   #   y: entity.y - 64,
        #   #   font_size: 1,
        #   #   text: "Done!",
        #   #   alignment_enum: 1,
        #   #   r: 255, g: 255, b: 255, a: 255,
        #   # }
        # else
        #   bordered_rect!(
        #     wrap_layout(container, rect({
        #       row: 0, col: 0, w: screen_w(max_w) * progress, h: 1,
        #     }))
        #   )
        #   # outputs[:scene].primitives << {
        #   #   x: entity.x - (max_w / 2),
        #   #   y: entity.y.from_top + entity.h + 20,
        #   #   w: max_w,
        #   #   h: 4,
        #   #   r: 255, g: 255, b: 255,
        #   #   primitive_marker: :solid,
        #   # }
        # end
      end
    end
  end
end
