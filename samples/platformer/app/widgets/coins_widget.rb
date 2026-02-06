class CoinsWidget < Hoard::Widget
  attr_accessor :coins

  def init
    @coins = 0
  end

  def render
    # Coin icon + count rendered as sprite-sheet images directly
    # (these are sprite-based digit displays, best kept as raw images)
    base_x = 0
    base_y = 32.from_top

    image(path: "samples/platformer/sprites/spritesheet-tiles-default.png",
          x: base_x, y: base_y,
          w: 64, h: 64, tile_w: 64, tile_h: 64,
          tile_x: 13 * 64, tile_y: 1 * 64)

    image(path: "samples/platformer/sprites/spritesheet-tiles-default.png",
          x: base_x + 32, y: base_y,
          w: 64, h: 64, tile_w: 64, tile_h: 64,
          tile_x: 13 * 64, tile_y: 3 * 64)

    coins.to_s.each_char.with_index do |char, i|
      image(path: "samples/platformer/sprites/spritesheet-tiles-default.png",
            x: base_x + 64 + (i * 42), y: base_y,
            w: 64, h: 64, tile_w: 64, tile_h: 64,
            tile_x: 13 * 64, tile_y: (13 - char.to_i) * 64)
    end
  end
end
