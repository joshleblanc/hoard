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
        $args.inputs.mouse.position.inside_rect?([rx, ry, rw, rh])
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

      def child_index
        @parent&.children&.index(self) || 0
      end

      def x() = parent&.x || 0
      def y() = parent&.y || 0

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
        [max_w, parent.w(max_w)].min
      end

      def h
        if @options[:h]
          if @options[:h].is_a?(String)
            (@options[:h].to_i / 100.0) * parent.h
          else
            @options[:h]
          end
        else
          (@children.max_by(&:h)&.h || 0)
        end
      end

      def rx() = x + (parent&.padding || 0)
      def ry() = y.from_top + (parent&.padding || 0)
      def rw() = w - ((parent&.padding || 0) * 2)
      def rh() = h - ((parent&.padding || 0) * 2)
    end
  end
end
