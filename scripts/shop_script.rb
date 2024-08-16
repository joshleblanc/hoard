module Hoard
  module Scripts
    class ShopScript < Script
      attr :catalog_id

      def init
        puts "catalog_id #{@catalog_id}"
      end

      def on_interact(player)
        puts entity
        puts entity.instance_variables
        entity.shop_widget.show!
      end

      def update
        return unless entity.shop_widget.visible?
        items = Game.s.player.playfab_script.search_items(store_id: @catalog_id)
        puts items
        entity.shop_widget.items = items
      end
    end
  end
end
