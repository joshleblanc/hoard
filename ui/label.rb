module Hoard 
    module Ui 
        class Label < Element 
            def render 
                $args.outputs[:ui].labels << {
                    x: rx, y: ry, w: rw, h: rh, 
                    text: text, size_enum: 1,
                    alignment_enum: 1,
                    vertical_alignment_enum: 1,
                    r: 255, g: 255, b: 255, a: 255
                }
            end
            
            def text 
                puts "Block #{@blk} #{@blk&.call}"
                @blk.call if @blk
            end

            def rx 
                x + parent.w / 2
            end

            def ry
                y + parent.h / 2
            end
        end
    end 
end