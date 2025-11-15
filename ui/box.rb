module Hoard
  module UI
    # Box is the fundamental layout component
    # It can contain children and lay them out horizontally or vertically
    class Box < BaseElement
      def initialize(parent: nil, **options, &block)
        super(parent: parent, **options)

        @block = block

        # Position and size - always explicit
        @x = options[:x] || 0
        @y = options[:y] || 0
        @w = options[:w] || nil  # nil means auto-size from children
        @h = options[:h] || nil  # nil means auto-size from children

        # Layout options
        @direction = options[:direction] || :vertical  # :vertical or :horizontal
        @gap = options[:gap] || 0
        @padding = options[:padding] || 0
        @align = options[:align] || :start  # :start, :center, :end
        @justify = options[:justify] || :start  # :start, :center, :end, :space_between

        # Visual options
        @background = options[:background]
        @border = options[:border]
        @border_color = options[:border_color] || [255, 255, 255, 255]

        # Interaction
        @on_click = options[:on_click]
        @on_hover = options[:on_hover]

        # Build children
        instance_eval(&block) if block
      end

      # Helper to create child boxes
      def box(**options, &block)
        Box.new(parent: self, **options, &block)
      end

      # Helper to create labels
      def label(**options, &block)
        Label.new(parent: self, **options, &block)
      end

      # Helper to create buttons
      def button(**options, &block)
        Button.new(parent: self, **options, &block)
      end

      # Helper to create images
      def image(**options)
        Image.new(parent: self, **options)
      end

      # Layout calculation - call this before rendering
      def layout(parent_x = nil, parent_y = nil, parent_w = 1280, parent_h = 720)
        # Use explicit x/y from options if set, otherwise use parent position
        if @options[:x]
          @x = @options[:x] + (@options[:offset_x] || 0)
        else
          @x = (parent_x || 0) + (@options[:offset_x] || 0) + @padding
        end

        if @options[:y]
          @y = @options[:y] - (@options[:offset_y] || 0)
        else
          @y = (parent_y || 0) - (@options[:offset_y] || 0) - @padding
        end

        # Calculate auto width/height from children if not explicit
        calculate_size(parent_w, parent_h)

        # Layout children
        layout_children
      end

      def calculate_size(parent_w, parent_h)
        # Handle percentage widths
        if @options[:w].is_a?(String) && @options[:w].end_with?('%')
          percent = @options[:w].to_i / 100.0
          @w = (parent_w - @padding * 2) * percent
        elsif @options[:w]
          @w = @options[:w]
        else
          # Auto-size from children
          @w = calculate_content_width
        end

        # Handle percentage heights
        if @options[:h].is_a?(String) && @options[:h].end_with?('%')
          percent = @options[:h].to_i / 100.0
          @h = (parent_h - @padding * 2) * percent
        elsif @options[:h]
          @h = @options[:h]
        else
          # Auto-size from children
          @h = calculate_content_height
        end
      end

      def calculate_content_width
        return @padding * 2 if @children.empty?

        if @direction == :horizontal
          # Sum children widths + gaps
          @children.sum { |c| c.content_width } + (@gap * (@children.length - 1)) + (@padding * 2)
        else
          # Max child width
          @children.map { |c| c.content_width }.max + (@padding * 2)
        end
      end

      def calculate_content_height
        return @padding * 2 if @children.empty?

        if @direction == :vertical
          # Sum children heights + gaps
          @children.sum { |c| c.content_height } + (@gap * (@children.length - 1)) + (@padding * 2)
        else
          # Max child height
          @children.map { |c| c.content_height }.max + (@padding * 2)
        end
      end

      # Content size (used by parent for layout)
      def content_width
        @w || calculate_content_width
      end

      def content_height
        @h || calculate_content_height
      end

      def layout_children
        return if @children.empty?

        if @direction == :horizontal
          layout_horizontal
        else
          layout_vertical
        end
      end

      def layout_horizontal
        # Calculate available space for children
        available_width = @w - (@padding * 2) - (@gap * (@children.length - 1))

        # Position children horizontally
        current_x = @x

        @children.each_with_index do |child, i|
          child_w = child.content_width
          child_h = @h - (@padding * 2)

          child.layout(current_x, @y, child_w, child_h)
          current_x += child_w + @gap
        end
      end

      def layout_vertical
        # Position children vertically (Y decreases going down in DragonRuby)
        current_y = @y

        @children.each_with_index do |child, i|
          child_w = @w - (@padding * 2)
          child_h = child.content_height

          child.layout(@x, current_y, child_w, child_h)
          current_y -= child_h + @gap
        end
      end

      # Rendering
      def render(args)
        # Render background
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

      # Interaction
      def update(args)
        handle_mouse(args)
        @children.each { |child| child.update(args) }
      end

      def handle_mouse(args)
        if mouse_inside?(args)
          @on_hover&.call if @on_hover

          if args.inputs.mouse.click
            @on_click&.call if @on_click
          end
        end
      end
    end
  end
end
