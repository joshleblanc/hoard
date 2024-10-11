module Hoard
    module Ui
        class Element 
            attr_reader :parent, :children, :options, :key

            def self.inherited(subclass)
                super
        
                define_method(subclass.name.split('::').last.downcase) do |**options, &blk|
                    subclass.new(parent: self, **options, &blk)
                end
            end

            def initialize(parent: nil, **options, &blk)
                @parent = parent
                @children = []
                @options = options

                @blk = blk

                @parent.children << self if @parent

                @key = options[:key] || caller.select { _1.include?("initialize") }.second.split(":").first

                instance_eval(&blk) if blk
            end

            def widget 
                @options[:widget] || parent&.widget
            end
            
            def state 
                $args.state.ui_state ||= {}
                $args.state.ui_state[key] ||= {}
            end

            def method_missing(method, *args, &blk)
                if @options.include?(method) && args.empty? && blk.nil?
                    @options[method]
                else
                    @parent&.send(method, *args, &blk)
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

            def render
                if @options[:border]
                    $args.outputs[:ui].borders << {
                        x: rx, y: ry, w: rw, h: rh,
                        r: @options[:border][:r] || 255,
                        g: @options[:border][:g] || 255,
                        b: @options[:border][:b] || 255,
                        a: @options[:border][:a] || 255
                    }
                end

                if @options[:background]
                    $args.outputs[:ui].sprites << {
                        x: rx, y: ry, w: rw, h: rh,
                        r: @options[:background][:r] || 0,
                        g: @options[:background][:g] || 0,
                        b: @options[:background][:b] || 0,
                        a: @options[:background][:a] || 255 
                    }
                end

            end

            def child_index 
                @parent&.children&.index(self) || 0
            end

            def x()= parent&.x || 0
            def y()= parent&.y || 0
            def w()= parent&.w || 0
            def h()= parent&.h || 0

            def rx()= x + (parent&.padding || 0)
            def ry()= y + (parent&.padding || 0)
            def rw()= w - ((parent&.padding || 0) * 2)
            def rh()= h - ((parent&.padding || 0) * 2)
        end
    end
end