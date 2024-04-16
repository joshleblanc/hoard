module Hoard 
    module Scripts
        class GravityScript < Script 
            def initialize(gravity = 0.05, landing_animation: nil) 
                @gravity = gravity
                @landing_animation = landing_animation
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

                if @landing_animation
                    Game.s.fx.anim(@landing_animation.merge({ x: entity.center_x, y: entity.center_y.from_top }))
                end
            end
        end
    end
end