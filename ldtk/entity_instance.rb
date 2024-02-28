module Hoard
    module Ldtk
        class EntityInstance < Base
            imports :grid, :identifier, :pivot, :smart_color, :tags, :tile, 
                        :world_x, :world_y, :def_uid, :field_instances, :height, 
                        :iid, :px, :width
        end
    end
end