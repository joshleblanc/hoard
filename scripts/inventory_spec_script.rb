module Hoard
  module Scripts
    class InventorySpecScript < Script
      attr :icon, :name, :sell_price, :max_stack

      def initialize(icon:, name:, sell_price: 0, max_stack: 0)
        @icon = icon
        @name = name
        @sell_price = sell_price
        @max_stack = max_stack
      end
    end
  end
end
