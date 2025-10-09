class CoinsWidget < Hoard::Widget
    attr_accessor :coins 

    def init 
        @coins = 0
    end

    def render
        window(key: :coins, x: 0, y: 0.from_top, w: 1280, h: 25, background: { color: { r: 125, g: 125, b: 125 }}) do
            text(justify: :left, align: :top,) { "Coins: #{coins}" }
        end
    end
end