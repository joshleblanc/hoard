module Hoard 
    module Scripts 
        class PickupScript < Script
            attr :quantity 

            def initialize(quantity: 1, persistant: true) 
                @quantity = quantity
                @persistant = persistant
            end

            def init 
                save_data = entity.save_data_script.init

                hide! if save_data.picked_up && @persistant
            end

            def show!
                entity.visible = true
                entity.destroyed = false
            end

            def hide!
                entity.visible = false
                entity.destroyed = true
            end

            def on_collision(player)
                player.send_to_scripts(:add_to_inventory, entity, @quantity)

                hide! 

                entity.send_to_scripts(:save, { picked_up: true }) if @persistant
            end
        end
    end
end