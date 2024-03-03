module Hoard
    module Ldtk 
        class EnumValueDefinition < Base
            imports :color, :id, :tile_id, :tile_src_rect, tile_rect: TilesetRect

            def tileset 
                tile_rect.tileset
            end
        end
    end
end