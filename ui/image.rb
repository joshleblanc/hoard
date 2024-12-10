module Hoard
  module Ui
    class Image < Element
      def render
        sprite(
          **@options,
          x: rx, y: ry, w: rw, h: rh,
        )
      end
    end
  end
end
