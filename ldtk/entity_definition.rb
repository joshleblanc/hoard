require_relative "tileset_rect"
require_relative "tileset_rect"

module Hoard
    module Ldtk
        class EntityDefinition < Base
            imports :color, :height, :identifier, :nine_slice_borders, :pivot_x,
                    :pivot_y, :tile_rect, :tile_render_mode, :tileset_id, :ui_tile_rect,
                    :uid, :width, :tile_id, tile_rect: TilesetRect, ui_tile_rect: TilesetRect

            def tileset 
                return unless tile_rect
                root.tileset(tile_rect.tileset_uid)
            end
        end
    end
end
