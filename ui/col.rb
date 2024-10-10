module Hoard 
    module Ui 
        class Col < Element
            COLS = 12 

            def render
                $args.outputs[:ui].borders << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 0, b: 255, a: 255
                }
    
                $args.outputs[:ui].sprites << {
                    x: rx, y: ry, w: rw, h: rh,
                    r: 0, g: 0, b: 0, a: 125
                }
            end

            def x
                range = (0...child_index)
                span_sum = range.to_a.sum { @parent.children[_1].span }
                index = (span_sum % COLS) / span
                @parent.x + (index * w)
            end 

            def y 
                range = (0..child_index)
                span_sum = range.to_a.sum { @parent.children[_1].span }
                parent.y - (h * ((span_sum) / COLS).ceil) + parent.h
            end

            def span 
                if @options[:span] && @options[:span] > 0 
                    @options[:span]
                else 
                    num_rows = (parent.children.length / COLS).floor

                    row_min = num_rows * COLS
                    row_max = (num_rows * COLS) + COLS

                    index = parent.children.index(self)


                    if index >= row_min
                        COLS / (COLS - (row_max - parent.children.length))
                    else
                        1
                    end
                end
            end

            def w 
                @parent.w / COLS * span
            end

            def h 
                (@children.max_by(&:h)&.h || 0) 
            end
        end
    end
end