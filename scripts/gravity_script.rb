module Hoard 
    module Scripts
        class GravityScript < Script 
            def initialize(gravity = 0.05) 
                @gravity = gravity
            end

            def update 
                entity.v_base.dy += @gravity unless entity.on_ground?
            end

            def on_pre_step_y 
                return unless entity.yr > 1
                return unless entity.has_collision(entity.cx, entity.cy + 1)

                entity.v_base.dy = 0
                entity.v_bump.dy = 0
                entity.yr = 1
                entity.fx.dots_explosion(entity.center_x, entity.center_y, 0xffcc00)
            end
        end
    end
end