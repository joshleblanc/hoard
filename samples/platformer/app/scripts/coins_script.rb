class CoinsScript < Hoard::Script
    def init
        @coins = 0
        @widget = entity.coins_widget
    end

    def add_to_inventory(_, amount)
        p "Adding to inventory"
        @coins += amount
        entity.coins_widget.coins = @coins
        entity.user.send_to_scripts(:play_audio, :coin_pickup)
    end
end