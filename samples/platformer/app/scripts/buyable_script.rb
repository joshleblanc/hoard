class BuyableScript < Hoard::Script 
    attr :price 
    attr :item

    def init 
        entity.label_script.label = "#{price} coins"
    end

    def on_interact(player)
        if player.user.coins_script.can_afford?(price)
            player.user.send_to_scripts(:add_notification, "", "You bought #{item}")
            player.user.send_to_scripts(:remove_from_inventory, nil, price)
            #player.inventory_script.add_to_inventory(item)
        else 
            player.user.send_to_scripts(:add_notification, "", "You don't have enough coins")
        end
    end
end