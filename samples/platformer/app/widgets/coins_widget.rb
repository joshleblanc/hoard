class CoinsWidget < Hoard::Widget
    attr_accessor :coins 

    MAP = {
        "0" => {
            tile_x: 13 * 64,
            tile_y: 13 * 64,
        }
    }

    def init 
        @coins = 0
    end

    def render
        window(key: :coins, x: 16, y: 32.from_top, w: 1280, h: 64) do
            row do 
                col(span: 0.5) do 
                    image(path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: 1 * 64)
                end
                col do 
                    coins.to_s.each_char.with_index do |char, i|
                        image(path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: (13 - char.to_i) * 64, offset_x: i > 0 ? -32 : 0)
                    end
                end
            end
        end
    end
end