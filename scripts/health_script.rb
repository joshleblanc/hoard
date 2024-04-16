module Hoard 
    module Scripts 
        class HealthScript < Script 
            attr :life, :last_dmg_source, :last_hit_dir_from_source, :last_hit_dir_to_source

            def initialize(health: 1)
                @life = Stat.new
                @life.init_max_on_max(health)
            end

            def reset!
                @life.reset!
            end

            def flash! 
                delay = 0.25 * 60
                flip = Proc.new do |s|
                    
                end

                Scheduler.schedule do |s, blk|
                    if entity.cd.has("invulnerability")
                        entity.visible = !entity.visible
                        s.wait(delay, &blk) 
                    else 
                        entity.visible = true
                    end
                end
            end

            def ricochet!(target)
                powaaa = 0.5
                normal = Geometry.vec2_normalize({ x: entity.x - target.x, y: entity.y - target.y})
                entity.v_base.y = powaaa * normal.y
                entity.v_base.x = powaaa * normal.x
            end

            def on_damage(amt, from = nil)
                return if amt <= 0
                return if dead?

                return if entity.cd.has("invulnerability")

                entity.cd.set_s("invulnerability", 3)

                flash!
                ricochet!(from)

                @life.v -= amt
                @last_dmg_source = from

                if @life.v <= 0 
                    entity.send_to_scripts(:on_die)
                end
            end

            def alive?
                @life.v > 0
            end

            def dead?
                !alive?
            end
        end
    end
end