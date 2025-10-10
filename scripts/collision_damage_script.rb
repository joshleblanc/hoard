module Hoard
    module Scripts
        class CollisionDamageScript < Script
            def on_collision(player)
                player.send_to_scripts(:apply_damage, 1, entity)
            end
        end
    end
end