class HealthWidget < Hoard::Widget
  SPRITESHEET = "samples/platformer/sprites/spritesheet-tiles-default.png"
  FULL  = { path: SPRITESHEET, w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: 0 }
  HALF  = { path: SPRITESHEET, w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 12 * 64, tile_y: 16 * 64 }
  EMPTY = { path: SPRITESHEET, w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 12 * 64, tile_y: 17 * 64 }

  def render
    base_x = 180.from_right
    base_y = 24.from_top

    entity.health_script.life.max.times do |i|
      next unless i % 2 == 1

      heart = if entity.health_script.life.v > i
                FULL
              elsif entity.health_script.life.v % 2 == 1 && i == entity.health_script.life.v
                HALF
              else
                EMPTY
              end

      image(**heart, x: base_x + (i / 2) * 56, y: base_y)
    end
  end
end
