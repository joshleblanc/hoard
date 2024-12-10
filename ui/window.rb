module Hoard
  module Ui
    class Window < Element
      def initialize(...)
        super(...)

        state[:dragging] = false
        state[:offset_x] = 0
        state[:offset_y] = 0
        state[:drag_x] = 0
        state[:drag_y] = 0
      end

      def x
        if @options[:x]
          @options[:x] + state[:offset_x]
        else
          super + state[:offset_x]
        end
      end

      def y
        if @options[:y]
          @options[:y] + state[:offset_y]
        else
          super + state[:offset_y]
        end
      end

      def drag
        if $args.inputs.mouse.button_left
          if $args.inputs.mouse.inside_rect?([rx, ry, rw, rh]) && !state[:dragging]
            state[:dragging] = true

            state[:drag_x] = $args.inputs.mouse.x - state[:offset_x]
            state[:drag_y] = $args.inputs.mouse.y - state[:offset_y]
          end
        else
          state[:dragging] = false
        end

        if state[:dragging]
          state[:offset_x] = $args.inputs.mouse.x - state[:drag_x]
          state[:offset_y] = $args.inputs.mouse.y - state[:drag_y]
        end
      end

      def render
        if @options[:x]
          drag
          super
        else
          super
        end
      end
    end
  end
end
