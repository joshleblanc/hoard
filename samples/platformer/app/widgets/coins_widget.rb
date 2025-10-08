class CoinsWidget < Hoard::Widget
    def render 
        p "rendering"
        window(key: :coins, x: 0, y: 0, width: 1280, h: 40) do 
            text("Coins: #{entity.coins}")
        end
    end
end