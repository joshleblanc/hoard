module Hoard
  module Scripts
    class PickupScript < Script
      attr :quantity

      def initialize(quantity: 1, persistant: true)
        @quantity = quantity
        @persistant = persistant
      end

      def client_init
        save_data = user.save_data_script.init

        if save_data[save_data_id] && @persistant
          hide! 
        else
          show!
          
        end
      end

      def save_data_id 
        "#{entity.ldtk_entity_script.id}_picked_up"
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
        player.user.send_to_scripts(:add_to_inventory, entity.inventory_spec_script, @quantity)
        player.user.user_quests_script&.complete_quest(entity.ldtk_entity_script.id)

        hide!

        player.user.send_to_scripts(:save_data, save_data_id, true) if @persistant
      end
    end
  end
end
