module Hoard
  module UI
    # Label renders text
    class Label < BaseElement
      def initialize(parent: nil, **options, &block)
        super(parent: parent, **options)

        @block = block

        # Position and size
        @x = options[:x] || 0
        @y = options[:y] || 0
        @w = options[:w] || nil
        @h = options[:h] || nil

        # Text options
        @size_enum = options[:size_enum] || 0
        @color = options[:color] || [255, 255, 255, 255]
        @align = options[:align] || :left  # :left, :center, :right
        @vertical_align = options[:vertical_align] || :top  # :top, :center, :bottom
      end

      # Get text from block
      def text
        @block ? @block.call.to_s : (@options[:text] || "")
      end

      # Calculate text dimensions
      def text_size
        @text_size_cache ||= {}
        t = text
        @text_size_cache[t] ||= $gtk.calcstringbox(t, @size_enum)
      end

      def text_width
        text_size[0]
      end

      def text_height
        text_size[1]
      end

      # Content size for layout
      def content_width
        @w || text_width
      end

      def content_height
        @h || text_height
      end

      # Layout
      def layout(parent_x, parent_y, parent_w, parent_h)
        @x = parent_x
        @y = parent_y
        @w = parent_w
        @h = parent_h
      end

      # Rendering
      def render(args)
        t = text
        return if t.empty?

        # Calculate text position based on alignment
        text_x = calculate_text_x
        text_y = calculate_text_y

        color = parse_color(@color)

        args.outputs[:ui].labels << {
          x: text_x,
          y: text_y,
          text: t,
          size_enum: @size_enum,
          **color
        }
      end

      def calculate_text_x
        case @align
        when :left
          @x
        when :center
          @x + (@w / 2) - (text_width / 2)
        when :right
          @x + @w - text_width
        else
          @x
        end
      end

      def calculate_text_y
        case @vertical_align
        when :top
          @y
        when :center
          @y - (@h / 2) + (text_height / 2)
        when :bottom
          @y - @h + text_height
        else
          @y
        end
      end

      # Override parse_color to default to white for text
      def parse_color(color)
        if color.is_a?(Array)
          { r: color[0] || 255, g: color[1] || 255, b: color[2] || 255, a: color[3] || 255 }
        elsif color.is_a?(Hash)
          { r: color[:r] || 255, g: color[:g] || 255, b: color[:b] || 255, a: color[:a] || 255 }
        else
          { r: 255, g: 255, b: 255, a: 255 }
        end
      end
    end
  end
end
