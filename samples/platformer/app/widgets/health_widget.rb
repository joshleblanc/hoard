class HealthWidget < Hoard::Widget 

    FULL = { path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 13 * 64, tile_y: 0}
    HALF = { path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 12 * 64, tile_y: 16 * 64 }
    EMPTY = { path: "samples/platformer/sprites/spritesheet-tiles-default.png", w: 64, h: 64, tile_w: 64, tile_h: 64, tile_x: 12 * 64, tile_y: 17 * 64 }

    def render
        args.outputs.debug << entity.health_script.life.max.to_s
        window(x: 180.from_right, y: 24.from_top, h: 64, w: 1280) do
            entity.health_script.life.max.times do |i|
                if i % 2 == 1
                    if entity.health_script.life.v > i
                        image(**FULL, offset_x: -8 * i)
                    elsif entity.health_script.life.v % 2 == 1 && i == entity.health_script.life.v
                        image(**HALF, offset_x: -8 * i)
                    else
                        image(**EMPTY, offset_x: -8 * i)
                    end
                end
                
            end
       end 
    end
end