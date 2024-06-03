module Hoard 
    module Scripts 
        class ProgressBarScript < Script
            attr_reader :limit, :curr

            def initialize(limit: 100) 
                @limit = limit
                @curr = 0
            end

            def progress 
                @curr / @limit   
            end
            
            def update 
                @curr += 1
                if progress >= 1
                    @curr = 0
                end
            end

            def max_w 
                entity.w * 2
            end

            def post_update 
                outputs[:scene].sprites << {
                    x: entity.x - (max_w / 4),
                    y: entity.y.from_top + entity.h + 20,
                    w: max_w * progress,
                    h: 4,
                    primitive_marker: :solid
                }
            end
        end
    end
end