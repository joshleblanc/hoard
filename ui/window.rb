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
        offset_x = state[:offset_x] || 0
        offset_x = 0 unless offset_x.is_a?(Numeric)
        
        if @options[:x]
          @options[:x] + offset_x
        else
          super + offset_x
        end
      end

      def y
        offset_y = state[:offset_y] || 0
        offset_y = 0 unless offset_y.is_a?(Numeric)
        
        if @options[:y]
          @options[:y] + offset_y
        else
          super + offset_y
        end
      end

      def drag
        # Ensure numeric state values
        state[:offset_x] = 0 unless state[:offset_x].is_a?(Numeric)
        state[:offset_y] = 0 unless state[:offset_y].is_a?(Numeric)
        state[:drag_x] = 0 unless state[:drag_x].is_a?(Numeric)
        state[:drag_y] = 0 unless state[:drag_y].is_a?(Numeric)
        
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
        end
        
        if @options[:border]
          border(
            x: rx, y: ry, w: rw, h: rh,
            r: @options[:border][:r] || 255,
            g: @options[:border][:g] || 255,
            b: @options[:border][:b] || 255,
            a: @options[:border][:a] || 255,
            anchor_x: 0,
            anchor_y: 1
          )
        end

        if @options[:background]
          sprite(
            x: rx, y: ry, w: rw, h: rh,
            r: @options[:background][:r] || 0,
            g: @options[:background][:g] || 0,
            b: @options[:background][:b] || 0,
            a: @options[:background][:a] || 255,
            anchor_x: 0,
            anchor_y: 1
          )
        end
      end

      def hovered?
        $args.inputs.mouse.position.inside_rect?([rx, ry, rw, rh])
      end
    end
  end
end
