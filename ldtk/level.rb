require_relative "field_instance"
require_relative "layer_instance"

module Hoard
    module Ldtk 
        class Level < Base

            ##
            # neighbours is an array of objects with the shape
            # dir, levelIid, levelUid

            ##
            # bg_pos is an object with the shape cropRect: [int, int, int, int], scale, topLeftpx
            imports :bg_color, :bg_pos, :neighbours, :bg_rel_path, :external_rel_path,
                    :identifier, :iid, :px_hei, :px_wid, :uid, :world_depth, :world_x, :world_y, 
                    field_instances: [FieldInstance], layer_instances: [LayerInstance]

            def has_collision(x, y)
                layer("Collisions")&.has_collision(x, y)
            end

            def layer(id)
                layer_instances.find { |i| i.identifier == id }
            end

            def world_pos_to_level_pos(x, y)
                [x - world_x, y - world_y]
            end

            def find_neighbour(cx, cy)
                x = cx * Const::GRID
                y = cy * Const::GRID

                neighbour = neighbours.each do |n|
                    level = root.level(iid: n["levelIid"])
                    inside = Geometry.intersect_rect?(
                        [x, y, Const::GRID, Const::GRID],
                        [level.world_x, level.world_y, level.px_wid, level.px_hei]
                    )

                    # $gtk.notify! [
                    #     [x, y, 16, 16],
                    #     [level.world_x, level.world_y, level.px_wid, level.px_hei]
                    # ]

                    return level if inside
                end

                nil
            end

            def outside?(cx, cy)
                layer("Collisions")&.int(cx, cy) == nil
                # entity.x <= 0 || entity.x >= px_wid || entity.y <= 0 || entity.y >= px_hei
            end

            def entity(id)
                layer("Entities")&.entity(id)
            end

            def draw_override(ffi_draw)
                layer_instances.reverse.map do |layer|
                    layer.auto_layer_tiles.map do |tile|
                        ffi_draw.draw_sprite_hash({
                            x: tile.px[0] ,
                            y: tile.px[1].from_top,
                            w: layer.grid_size,
                            h: layer.grid_size,
                            tile_x: tile.src[0],
                            tile_y: tile.src[1],
                            tile_w: layer.grid_size,
                            tile_h: layer.grid_size,
                            path: "data/sample-platformer/#{layer.tileset_rel_path}",
                            flip_horizontally: tile.f == 1 || tile.f == 3,
                            flip_vertically: tile.f == 2 || tile.f == 3,
                            anchor_x: 0,
                            anchor_y: 0
                        })
                    end
                end.flatten
            rescue Exception => e 
                puts e
            end
        end
    end
end