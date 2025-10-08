require_relative "field_instance"
require_relative "layer_instance"

module Hoard
  module Ldtk
    class Level < Base
      include Serializable

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
        x = cx * ::Game::GRID
        y = cy * ::Game::GRID

        neighbour = neighbours.each do |n|
          level = root.level(iid: n.levelIid)
          inside = Geometry.intersect_rect?(
            [x, y, ::Game::GRID, ::Game::GRID],
            [level.world_x, level.world_y, level.px_wid, level.px_hei]
          )

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

      def entities(id = nil)
        layer("Entities")&.entities(id) || []
      end

      def draw_override(ffi_draw)
        Array.each(layer_instances.reverse) do |layer|
          a = 255 * layer.opacity
          path = layer.tileset_rel_path&.gsub("../", "") || ""
          grid_size = layer.grid_size

          Array.each(layer.tiles) do |tile|
            # The argument order for ffi_draw.draw_sprite_3 is:
            # x, y, w, h,
            # path,
            # angle,
            # alpha, red_saturation, green_saturation, blue_saturation
            # tile_x, tile_y, tile_w, tile_h,
            # flip_horizontally, flip_vertically,
            # angle_anchor_x, angle_anchor_y,
            # source_x, source_y, source_w, source_h
            #p "drawing tile #{tile.px[0]}, #{tile.px[1]}, #{layer.tileset_rel_path}"
            x = tile.px[0]
            y = tile.px[1]
            p "Drawing tile #{x}, #{y}, #{px_hei}"

            ffi_draw.draw_sprite_3(
              x, y, grid_size, grid_size,
              path, 0, a, 255, 255, 255,
              tile.src[0], tile.src[1], grid_size, grid_size,
              tile.f == 1 || tile.f == 3,
              !(tile.f == 2 || tile.f == 3),
              0.5, 0.5,
              nil, nil, nil, nil
            )
          end
        end
      rescue Exception => e
        puts e
      end
    end
  end
end
