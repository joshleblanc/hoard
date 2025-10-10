module Hoard
    module Scripts
        class CollisionDamageScript < Script
            def on_collision(player)
                player.apply_damage(1, entity)
            end
        end
    end
end