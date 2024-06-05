module Hoard 
    module Scripts 
        class PickupScript < Script
            attr :quantity 

            def initialize(quantity: 1) 
                @quantity = quantity
            end

            def on_collision(player)
                player.send_to_scripts(:add_to_inventory, entity, @quantity)
                entity.visible = false
                entity.destroyed = true
            end
        end
    end
end