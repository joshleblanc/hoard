module Hoard 
    module Ui 
        class Row < Element 
            def y 
                offset = @parent.children[0...child_index].sum(&:h)
                @parent.y - offset - h
            end

            def w(requester = nil)
                parent.w
            end

            def h 
                max_height = (@children.max_by(&:h)&.h || 0)
                num_rows = (@children.sum(&:span) / Col::COLS).ceil

                max_height * num_rows
            end
        end 
    end
end