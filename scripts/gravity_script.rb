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

                Game.s.fx.anim({
                    path: "sprites/effects.png",
                    x: entity.center_x,
                    y: entity.center_y.from_top,
                    tile_w: 64,
                    tile_h: 64,
                    tile_x: 0,
                    tile_y: 8 * 64,
                    frames: 11
                })

                #Game.s.fx.dots_explosion(entity.center_x, entity.center_y, 0xffffff)
            end
        end
    end
end