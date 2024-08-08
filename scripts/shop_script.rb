module Hoard
  module Scripts
    class ShopScript < Script
      attr :catalog_id

      def on_interact(player)
        entity.shop_widget.items = player.loot_locker_script.catalog(@catalog_id)
      end
    end
  end
end
