module Hoard 
    module Ui 
        class Label < Element 
            def render 
                $args.outputs[:ui].labels << {
                    x: rx, y: ry, w: rw, h: rh, 
                    text: text, 
                    size_enum: size_enum,
                    alignment_enum: 0,
                    vertical_alignment_enum: 0,
                    r: 255, g: 255, b: 255, a: 255
                }
            end

            def size_enum 
                @options[:size_enum] || 1
            end
            
            def text 
                @blk.call&.to_s if @blk
            end

            def rx 
                justify = @options[:justify]
                if justify == :left 
                    super
                elsif justify == :right
                    parent.x + parent.w - (parent.padding * 2)
                else 
                    sbw, _ = $gtk.calcstringbox(text, size_enum)
                    parent.x + (parent.w / 2) - (sbw / 2)
                end
            end

            def ry
                align = @options[:align]
                if align == :top
                    _, sbh = $gtk.calcstringbox(text, size_enum)
                    parent.y + parent.h - (parent.padding) - sbh
                elsif align == :bottom
                    super
                else
                    _, sbh = $gtk.calcstringbox(text, size_enum)
                    parent.y + (parent.h / 2) - (sbh / 2)
                end
            end
        end
    end 
end