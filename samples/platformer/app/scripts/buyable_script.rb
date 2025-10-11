class BuyableScript < Hoard::Script 
    attr :price, :item
    
    def init 
        entity.label_script.label = "#{price} coins"
    end

    def on_interact(player)
        if player.user.coins_script.can_afford?(price) 
            player.user.send_to_scripts(:remove_from_inventory, nil, price)
            player.user.send_to_scripts(:add_notification, "", "Bought #{item}")
        else 
            player.user.send_to_scripts(:add_notification, "", "Not enough coins")
        end
    end
end
    