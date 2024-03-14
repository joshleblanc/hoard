module Hoard 
    module Scripts
        class HorizontalMovementScript < Script
            def update
                entity.v_base.dx = (entity.v_base.dx + entity.walk_speed) * 0.085 if entity.walk_speed != 0 
            end
        end
    end
end