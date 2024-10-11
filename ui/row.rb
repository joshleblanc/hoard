module Hoard 
    module Ui 
        class Row < Element 
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