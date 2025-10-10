module Hoard
  module Ui
    class Image < Element
      def render
        sprite(
          **@options,
          x: rx, y: ry, w: rw, h: rh,
          anchor_x: 0,
          anchor_y: 1
        )
      end
    end
  end
end
