module Hoard 
    module Ui 
        class Row < Element 
            def y 
                offset = @parent.children[0...child_index].sum(&:h)
                @parent.y - offset - h
            end

            def w(requester = nil)
                return @options[:w] if @options[:w]
                # Use parent's explicit width to avoid recursion
                # Traverse up to find an ancestor with explicit width
                ancestor = parent
                while ancestor && !ancestor.options[:w]
                    ancestor = ancestor.parent
                end
                parent_width = ancestor&.options&.[](:w) || 1280 # fallback to screen width
                parent_width - (parent&.padding || 0) * 2
            end

            def h
                return 0 if @children.empty?

                max_height = (@children.max_by(&:h)&.h || 0)
                # Only sum span for Col elements that respond to span
                total_span = @children.select { |c| c.respond_to?(:span) }.sum(&:span)
                num_rows = total_span > 0 ? (total_span / Col::COLS).ceil : 1

                max_height * num_rows
            end
        end 
    end
end