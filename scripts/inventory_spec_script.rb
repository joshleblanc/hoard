module Hoard 
    module Scripts
        class InventorySpecScript < Script 
            attr :icon, :name

            def initialize(icon:, name:)
                @icon = icon
                @name = name
            end

            def to_h 
                {
                    icon: @icon,
                    name: @name
                }
            end

            def serialize 
                to_h
            end

            def to_s 
                serialize.to_s
            end
        end
    end
end