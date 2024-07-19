module Hoard
module Scripts
  class LootLockerCurrencyGiftScript < Hoard::Script 
    def initialize(currency_id:, quantity: 1)
      @currency_id = currency_id    
      @quantity = quantity
    end
  
    def on_collision(player)
      player.send_to_scripts(:add_currency, @currency_id, @quantity)
    end
  end
end
end