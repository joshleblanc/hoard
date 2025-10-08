class CoinsScript < Script
    def init
        @coins = 0
        @widget = entity.coins_widget
    end

    def add_to_inventory(_, amount)
        @coins += amount
    end
end