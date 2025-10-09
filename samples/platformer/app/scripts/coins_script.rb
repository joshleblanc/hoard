class CoinsScript < Hoard::Script
    def init
        @coins = entity.user.save_data_script.get_data("coins_total") || 0
        @widget = entity.coins_widget

        # set the coins next tick
        schedule do |s, &blk|
            s.wait(1, &blk)
            @widget.coins = @coins
        end
    end

    def add_to_inventory(_, amount)
        @coins += amount
        @widget.coins = @coins
        entity.user.send_to_scripts(:play_audio, :coin_pickup)
        entity.user.send_to_scripts(:save_data, "coins_total", @coins)
    end
end