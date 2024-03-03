module Hoard
    module Ldtk 
        class TilesetRect < Base
            imports :h, :w, :x, :y, :tileset_uid

            def tileset 
                root.tileset(tileset_uid)
            end
        end
    end
end