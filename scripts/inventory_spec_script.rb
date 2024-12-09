module Hoard
  module Scripts
    class InventorySpecScript < Script
      attr :icon, :name, :sell_price, :max_stack, :description

      class << self 
        def [](name)
          @@specs[name]
        end
      end

      def initialize(icon:, name:, sell_price: 0, max_stack: 0, description: "")
        @icon = icon
        @name = name
        @sell_price = sell_price
        @max_stack = max_stack
        @description = description

        @@specs ||= {}
        @@specs[name] = self
      end
    end
  end
end
