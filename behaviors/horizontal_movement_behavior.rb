module Hoard
    module Behaviors
        module HorizontalMovementBehavior
            def update(args)
                super 

                v_base.dx = (v_base.dx + @walk_speed) * 0.085 if @walk_speed != 0 
            end
        end
    end
end
