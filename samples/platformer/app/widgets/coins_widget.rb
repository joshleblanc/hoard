class CoinsWidget < Hoard::Widget
    attr_accessor :coins 

    def init 
        @coins = 0
    end

    def render
        window(key: :coins, x: 0, y: 0, w: 1280, h: 40) do
            text { "Coins: #{coins}" }
        end
    end
end