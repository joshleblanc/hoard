module Hoard
  module UI
    # BaseElement provides common functionality for all UI elements
    class BaseElement
      attr_accessor :x, :y, :w, :h
      attr_accessor :children, :parent
      attr_reader :options, :key

      def initialize(parent: nil, **options)
        @parent = parent
        @children = []
        @options = options

        # Inherit widget from parent if not explicitly set
        if !@options[:widget] && parent
          @options[:widget] = parent.find_widget
        end

        @key = options[:key] || "#{self.class.name.split('::').last.downcase}_#{object_id}"

        if parent
          @key = "#{parent.key}::#{@key}"
        end

        # Add to parent
        parent.children << self if parent
      end

      # Method missing allows accessing:
      # 1. Options as methods (e.g., @options[:background] via background())
      # 2. Parent methods
      # 3. Widget methods (if widget is set in options)
      def method_missing(method, *args, &block)
        # First check if it's an option
        if @options.include?(method) && args.empty? && block.nil?
          return @options[method]
        end

        # Check if parent responds to this method
        if @parent&.respond_to?(method)
          return @parent.send(method, *args, &block)
        end

        # Check if widget is set and responds to method
        widget_obj = find_widget
        if widget_obj&.respond_to?(method)
          return widget_obj.send(method, *args, &block)
        end

        # If nothing found, raise NoMethodError
        super
      end

      def respond_to_missing?(method, include_private = false)
        @options.include?(method) ||
          (@parent && @parent.respond_to?(method, include_private)) ||
          (find_widget && find_widget.respond_to?(method, include_private)) ||
          super
      end

      # Find widget by traversing up the tree
      def find_widget
        return @options[:widget] if @options[:widget]
        return @parent.find_widget if @parent.respond_to?(:find_widget)
        nil
      end

      # State management - scoped to this element's key
      def state
        $args.state.ui_state ||= {}
        $args.state.ui_state[@key] ||= {}
      end

      # Helper to parse color arrays or hashes
      def parse_color(color)
        if color.is_a?(Array)
          { r: color[0] || 0, g: color[1] || 0, b: color[2] || 0, a: color[3] || 255 }
        elsif color.is_a?(Hash)
          { r: color[:r] || 0, g: color[:g] || 0, b: color[:b] || 0, a: color[:a] || 255 }
        else
          { r: 0, g: 0, b: 0, a: 255 }
        end
      end

      # Check if mouse is inside this element
      def mouse_inside?(args)
        return false unless @x && @y && @w && @h
        args.inputs.mouse.position.inside_rect?([
          @x - (@padding || 0),
          @y - @h + (@padding || 0),
          @w,
          @h
        ])
      end

      # Default implementations - override in subclasses
      def content_width
        @w || 0
      end

      def content_height
        @h || 0
      end

      def layout(parent_x = 0, parent_y = 720, parent_w = 1280, parent_h = 720)
        # Override in subclasses
      end

      def update(args)
        # Override in subclasses
      end

      def render(args)
        # Override in subclasses
      end
    end
  end
end
