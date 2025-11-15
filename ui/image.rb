module Hoard
  module UI
    # Image renders a sprite
    class Image < BaseElement
      def initialize(parent: nil, **options)
        super(parent: parent, **options)

        # Position and size
        @x = options[:x] || 0
        @y = options[:y] || 0
        @w = options[:w] || 64
        @h = options[:h] || 64

        # Sprite options
        @path = options[:path] || 'sprites/square/blue.png'
        @tile_x = options[:tile_x] || 0
        @tile_y = options[:tile_y] || 0
        @tile_w = options[:tile_w] || @w
        @tile_h = options[:tile_h] || @h
        @angle = options[:angle] || 0
        @flip_horizontally = options[:flip_horizontally] || false
        @flip_vertically = options[:flip_vertically] || false
        @color = options[:color] || [255, 255, 255, 255]
      end

      # Content size for layout
      def content_width
        @w
      end

      def content_height
        @h
      end

      # Layout
      def layout(parent_x, parent_y, parent_w, parent_h)
        @x = parent_x
        @y = parent_y
        # Use explicit size, don't override from parent
      end

      # Rendering
      def render(args)
        color = parse_color(@color)

        sprite_hash = {
          x: @x,
          y: @y - @h,  # DragonRuby sprites use bottom-left origin
          w: @w,
          h: @h,
          path: @path,
          angle: @angle,
          flip_horizontally: @flip_horizontally,
          flip_vertically: @flip_vertically,
          **color
        }

        # Add tile properties if using spritesheet
        if @tile_x != 0 || @tile_y != 0 || @tile_w != @w || @tile_h != @h
          sprite_hash[:tile_x] = @tile_x
          sprite_hash[:tile_y] = @tile_y
          sprite_hash[:tile_w] = @tile_w
          sprite_hash[:tile_h] = @tile_h
        end

        args.outputs[:ui].sprites << sprite_hash
      end

      # Override parse_color to default to white for images
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
