module Hoard 
    module Ui 
        class Row < Element 
            def render
                $args.outputs[:ui].borders << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 255, b: 0
                }
    
                $args.outputs[:ui].sprites << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 0, b: 0, a: 125
                }
            end

            def y 
                @parent.y - ((@parent.children.index(self) + 1) * h) + parent.h
            end

            def h 
                max_height = (@children.max_by(&:h)&.h || 0)
                num_rows = (@children.sum(&:span) / Col::COLS).ceil

                max_height * num_rows
            end
        end 
    end
end