module Hoard 
    module Ui 
        class Col < Element
            COLS = 12 

            def rx
                range = (0...child_index)
                span_sum = range.to_a.sum { @parent.children[_1].span }
                index = (span_sum % COLS) / span
                @parent.rx + (index * w)
            end 

            def ry 
                range = (0...child_index)
                span_sum = range.to_a.sum { @parent.children[_1].span }
                row_index = (span_sum / COLS).floor
                parent.ry - (h * row_index)
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

            def w(requester = nil)
                return @options[:w] if @options[:w]
                # Use parent's explicit width to avoid recursion
                # Traverse up to find an ancestor with explicit width
                ancestor = @parent
                while ancestor && !ancestor.options[:w]
                    ancestor = ancestor.parent
                end
                parent_width = ancestor&.options&.[](:w) || 1280 # fallback to screen width
                parent_width / COLS * span
            end

            def h 
                (@children.max_by(&:h)&.h || 0) 
            end
        end
    end
end