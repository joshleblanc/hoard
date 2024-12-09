module Hoard 
    module Ui 
        class Label < Element 
            def render 
                line_y = ry
                wrapped_text.each do |line|
                    line_height = $gtk.calcstringbox(line, size_enum)[1]
                    $args.outputs[:ui].labels << {
                        x: rx, y: line_y, w: rw, h: rh, 
                        text: line,
                        size_enum: size_enum,
                        alignment_enum: 0,
                        vertical_alignment_enum: 1,
                        r: 255, g: 255, b: 255, a: 255
                    }
                    line_y -= line_height
                end
                
            end

            def size_enum 
                @options[:size_enum] || 1
            end
            
            def text 
                @blk.call&.to_s if @blk
            end

            def wrapped_text
                return [] unless text
                words = text.split(" ")
                lines = []
                current_line = []
                current_width = 0
                
                words.each_with_index do |word, i|
                    word_width, _ = if i == words.length - 1
                        $gtk.calcstringbox(word, size_enum)
                    else 
                        $gtk.calcstringbox(word + " ", size_enum)
                    end
                    
                    if w - (current_width + word_width) < -0.00001 
                        lines << current_line.join(" ")
                        current_line = [word]
                        current_width = word_width
                    else
                        current_line << word
                        current_width += word_width
                    end
                end
                
                lines << current_line.join(" ") unless current_line.empty?
                lines
            end

            def w 
                max_w = $gtk.calcstringbox(text, size_enum)[0]
                request_w(max_w)
            end

            def h
                wrapped_text.sum { |line| $gtk.calcstringbox(line, size_enum)[1] }
            end

            def rx 
                justify = @options[:justify]
                if justify == :left 
                    super
                elsif justify == :right
                    parent.rx + parent.w - (parent.padding * 2) - w
                else 
                    parent.rx + (parent.w / 2) - (w / 2)
                end
            end

            def ry
                align = @options[:align]
                if align == :top
                    parent.y + parent.h - (parent.padding) - h
                elsif align == :bottom
                    super
                else
                    parent.y + (parent.h / 2) + (h / 2) - ($gtk.calcstringbox(wrapped_text.first, size_enum)[1] / 2)
                end
            end
        end
    end 
end