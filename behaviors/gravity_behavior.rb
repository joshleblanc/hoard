module Hoard
    module Behaviors
        module GravityBehavior
            def update(args)
                super
                v_base.dy += 0.05 unless on_ground?
            end

            def on_pre_step_y
                super 

                return unless yr > 1 
                return unless has_collision(cx, cy + 1)
                
                self.squash_y = 0.5
                v_base.dy = 0
                v_bump.dy = 0 
                self.yr = 1
                fx.dots_explosion(center_x, center_y, 0xffcc00)
            end
        end
    end
end
