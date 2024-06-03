module Hoard 
    module Entities 
        class Coin < Entity 
            script Scripts::InventorySpecScript.new(
                icon: {
                    path: "sprites/fantasy/props.png",
                    
                }
            )
        end
    end
end
