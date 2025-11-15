module Hoard
  module UI
    # Panel is a draggable window/container
    class Panel < Box
      def initialize(**options, &block)
        @draggable = options[:draggable] != false  # Default to true
        super(**options, &block)
      end

      def layout(parent_x = 0, parent_y = 720, parent_w = 1280, parent_h = 720)
        # Panel uses absolute positioning with drag offset
        base_x = @options[:x] || 0
        base_y = @options[:y] || 720

        # Apply drag offset
        @x = base_x + (state[:offset_x] || 0) + @padding
        @y = base_y + (state[:offset_y] || 0) - @padding

        # Calculate size
        calculate_size(parent_w, parent_h)

        # Layout children
        layout_children
      end

      def update(args)
        handle_drag(args) if @draggable
        super(args)
      end

      def handle_drag(args)
        # Initialize state
        state[:dragging] ||= false
        state[:offset_x] ||= 0
        state[:offset_y] ||= 0
        state[:drag_start_x] ||= 0
        state[:drag_start_y] ||= 0

        if args.inputs.mouse.button_left
          if mouse_inside?(args) && !state[:dragging]
            # Start dragging
            state[:dragging] = true
            state[:drag_start_x] = args.inputs.mouse.x - state[:offset_x]
            state[:drag_start_y] = args.inputs.mouse.y - state[:offset_y]
          end
        else
          # Stop dragging
          state[:dragging] = false
        end

        if state[:dragging]
          # Update offset based on mouse position
          state[:offset_x] = args.inputs.mouse.x - state[:drag_start_x]
          state[:offset_y] = args.inputs.mouse.y - state[:drag_start_y]
        end
      end

      def render(args)
        # Re-layout with drag offset before rendering
        layout

        # Render panel
        super(args)

        # Render drag handle indicator if draggable
        if @draggable && mouse_inside?(args)
          args.outputs[:ui].borders << {
            x: @x - @padding,
            y: @y - @h + @padding,
            w: @w,
            h: @h,
            r: 255, g: 255, b: 0, a: 100
          }
        end
      end
    end
  end
end
