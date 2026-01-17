require_relative "tile_instance"
require_relative "entity_instance"

module Hoard
  module Ldtk
    class LayerInstance < Base
      imports :c_hei, :c_wid, :grid_size, :identifier, :opacity, :px_total_offset_x,
              :px_total_offset_y, :tileset_def_uid, :tileset_rel_path, :type,
              :int_grid_csv, :layer_def_uid, :level_id, :override_tileset_uid,
              :px_offset_x, :px_offset_y, :visible, :int_grid, :iid,
              auto_layer_tiles: [TileInstance], entity_instances: [EntityInstance],
              grid_tiles: [TileInstance]

      def has_collision(x, y)
        int(x, y).to_i == 1
      end

      def tiles
        if grid_tiles.length > 0
          grid_tiles
        elsif auto_layer_tiles.length > 0
          auto_layer_tiles
        else
          []
        end
      end

      def int(cx, cy)
        return 1 if cy < 0
        return 1 if cx < 0
        return 1 if cx >= c_wid
        return 1 if cy >= c_hei
        pos = cx + (cy * c_wid)
        int_grid_csv[pos]
      end

      def entity(id)
        entity_instances.find { |i| i.iid == id }
      end

      def entities(id = nil)
        if id.nil?
          entity_instances
        else
          entity_instances.select { |i| i.iid == id }
        end
      end

      def tile_rects
        @tile_rects ||= tiles.map.with_index do |tile, index|
          [tile.px[0], tile.px[1], grid_size, grid_size, index]
        end
      end

      def tiles
        @tiles ||= if auto_layer_tiles.length > 0
            auto_layer_tiles
          elsif grid_tiles.length > 0
            grid_tiles
          else
            []
          end
      end
    end
  end
end
