module Hoard
  module UI
    # Button is an interactive box with hover and click states
    class Button < Box
      def initialize(**options, &block)
        @hover_color = options[:hover_color] || [100, 100, 100, 200]
        @normal_color = options[:normal_color] || [50, 50, 50, 200]
        @pressed_color = options[:pressed_color] || [150, 150, 150, 200]

        # Set background to normal by default if not specified
        options[:background] ||= @normal_color

        super(**options, &block)
      end

      def update(args)
        handle_button_interaction(args)
        super(args)
      end

      def handle_button_interaction(args)
        if mouse_inside?(args)
          # Track hover state
          if !state[:hovered]
            state[:hovered] = true
            @on_hover&.call
          end

          # Update background to hover color
          @background = @hover_color

          # Handle click
          if args.inputs.mouse.button_left
            @background = @pressed_color
          end

          if args.inputs.mouse.click
            @on_click&.call if @on_click
          end
        else
          # Not hovering
          if state[:hovered]
            state[:hovered] = false
          end

          # Reset to normal color
          @background = @normal_color
        end
      end

      def render(args)
        # Render button background with current state
        if @background
          color = parse_color(@background)
          args.outputs[:ui].solids << {
            x: @x - @padding,
            y: @y - @h + @padding,
            w: @w,
            h: @h,
            **color
          }
        end

        # Render border
        if @border
          color = parse_color(@border_color)
          args.outputs[:ui].borders << {
            x: @x - @padding,
            y: @y - @h + @padding,
            w: @w,
            h: @h,
            **color
          }
        end

        # Render children
        @children.each { |child| child.render(args) }
      end
    end
  end
end
