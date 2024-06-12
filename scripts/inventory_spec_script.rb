module Hoard 
    module Scripts
        class InventorySpecScript < Script 
            attr :icon, :name, :sell_price

            def initialize(icon:, name:, sell_price: 0)
                @icon = icon
                @name = name
                @sell_price = sell_price
            end
        end
    end
end