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
                layer_instances.each do |layer|
                    collision = layer.has_collision(x, y)
                    return collision if collision
                end

                nil
            end

            def render
                layer_instances.reverse.map do |layer|
                    layer.auto_layer_tiles.map do |tile|
                        {
                            x: tile.px[0] ,
                            y: ($args.grid.h - tile.px[1]),
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
                        }
                    end
                end.flatten
            end
        end
    end
end