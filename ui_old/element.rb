module Hoard
  module Ui
    require_relative 'element_pool'

    class Element
      attr_reader :parent, :children, :options, :key

      def self.inherited(subclass)
        super

        define_method(subclass.name.split("::").last.downcase) do |**options, &blk|
          element_key = options[:key] || caller.first.split(":in").first
          element_key = key.to_s + "::" + element_key.to_s
          
          ElementPool.instance.acquire(subclass, element_key, parent: self, **options, &blk)
        end
      end

      def initialize(parent: nil, **options, &blk)
        @parent = parent
        @children = []
        
        @blk = blk

        @parent.children << self if @parent

        @key = options[:key] || caller[2].split(":in").first
        @key = @key.to_s

        if parent
          @key = parent.key + "::" + @key
        end

        #p "initialize key: #{key}"

        update_options(**options)
      end

      def update_options(**options, &blk)
        @parent.children << self if @parent
        @children = [] # blk should populate this 
        @options = options
        @blk = blk
        instance_eval(&blk) if blk
      end

      def sprite(hash)
        $args.outputs[:ui].sprites << hash
      end

      def label(hash)
        $args.outputs[:ui].labels << hash
      end

      def solid(hash)
        $args.outputs[:ui].solids << hash
      end

      def border(hash)
        $args.outputs[:ui].borders << hash
      end

      def debug(hash)
        $args.outputs[:ui].debug << hash
      end

      def widget
        @options[:widget] || parent&.widget
      end

      def state
        $args.state.ui_state ||= {}
        $args.state.ui_state[key] ||= {}
      end

      def hovered?
        $args.inputs.mouse.position.inside_rect?([rx, y, rw, h])
      end

      def method_missing(method, *args, &blk)
        if @options.include?(method) && args.empty? && blk.nil?
          @options[method]
        elsif @parent&.respond_to?(method)
          @parent&.send(method, *args, &blk)
        elsif widget&.respond_to?(method)
          widget&.send(method, *args, &blk)
        else
          raise NoMethodError
        end
      end

      def padding
        (@options[:padding] || 2) + (parent&.padding || 0)
      end

      def margin
        (@options[:margin] || 2) + (parent&.margin || 0)
      end

      def each(&blk)
        @children.each do |child|
          child.each(&blk) if child.respond_to?(:each)
          blk.call(child) if blk
        end
      end

      def update; end
      def post_update; end

      def pre_update
        if hovered?
          if @options[:on_mouse_enter] && !state[:hovered]
            @options[:on_mouse_enter].call
          end

          state[:hovered] = true
          if $args.inputs.mouse.click
            if @options[:on_click]
              @options[:on_click].call
            end
          end
        elsif state[:hovered]
          if @options[:on_mouse_exit]
            @options[:on_mouse_exit].call
          end

          state[:hovered] = false
        end
      end

      def render
        if @options[:border]
          if @options[:border].is_a?(Array)
            border(
              x: rx, y: ry, w: rw, h: rh,
              r: @options[:border][0],
              g: @options[:border][1],
              b: @options[:border][2],
              a: @options[:border][3],
              anchor_x: 0,
              anchor_y: 1
            )
          else
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
        end

        if @options[:background]
          if @options[:background].is_a?(Array)
            sprite(
              x: rx, y: ry, w: rw, h: rh,
              r: @options[:background][0],
              g: @options[:background][1],
              b: @options[:background][2],
              a: @options[:background][3],
              anchor_x: 0,
              anchor_y: 1
            )
          else
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
      end

      def child_index
        @parent&.children&.index(self) || 0
      end

      def x
        return @options[:x] if @options[:x]
        parent&.x || 0
      end

      def y
        return @options[:y] if @options[:y]
        parent&.y || 0
      end

      def w(max_w = nil)
        if @options[:w]
          if @options[:w].is_a?(String)
            (@options[:w].to_i / 100.0) * parent.w
          else
            @options[:w]
          end
        else
          if max_w
            request_w(max_w)
          else
            (@children.map(&:w).sum || 0)
          end
        end
      end

      def request_w(max_w = Float::INFINITY)
        parent_width = parent ? (parent.options[:w] || max_w) : max_w
        [max_w, parent_width].min
      end

      def h
        if @options[:h]
          if @options[:h].is_a?(String)
            (@options[:h].to_i / 100.0) * parent.h
          else
            @options[:h]
          end
        else
          children_height = (@children.max_by(&:h)&.h || 0)
          children_height + ((@options[:padding] || 0) * 2)
        end
      end

      def rx
        base = if @options[:x]
          x
        else
          base_x = (parent&.rx || 0) + (parent&.padding || 0)

          # Add offset based on previous siblings' widths (horizontal flow)
          if parent && child_index > 0
            gap = parent.options[:gap] || 0
            offset = (0...child_index).to_a.sum { |i| parent.children[i].w + gap }
            base_x + offset
          else
            base_x
          end
        end

        # Apply element's own offset
        base + (@options[:offset_x] || 0)
      end

      def ry
        base = if @options[:y]
          y
        else
          # In DragonRuby, y goes bottom-to-top, so subtract padding to go "down" visually
          (parent&.ry || 0) - (parent&.padding || 0)
        end

        # Apply element's own offset
        base + (@options[:offset_y] || 0)
      end

      def rw
        w
      end

      def rh
        h
      end
    end
  end
end
