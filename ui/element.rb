module Hoard
    module Ui
        class Element 
            attr_reader :parent, :children, :options

            def self.inherited(subclass)
                super
                puts "New subclass: #{subclass} #{subclass.name.split('::').last.downcase}"
        
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

                instance_eval(&blk) if blk
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
                puts "Calling each #{@children.count}"
                @children.each do |child|
                    child.each(&blk) if child.respond_to?(:each)
                    blk.call(child) if blk
                end
            end

            def render
                $args.outputs[:ui].borders << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 0, b: 0
                }

                $args.outputs[:ui].sprites << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 0, b: 0, a: 125
                }
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