module Hoard
    module Ldtk 
        class FieldInstance < Base
            imports :identifier, :type, :value, :def_uid, tile: TilesetRect
        end
    end
end