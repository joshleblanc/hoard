class CoinsWidget < Hoard::Widget
    attr_accessor :coins 

    def init 
        @coins = 0
    end

    def render
        window(key: :coins, x: 0, y: 32.from_top, w: 720, h: 64) do
            image(path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: 1 * 64, offset_x: 32)
            image(path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: 3 * 64, offset_x: 32)
            coins.to_s.each_char.with_index do |char, i|
                image(path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: (13 - char.to_i) * 64, offset_x: i * -42)
            end
        end
    end
end