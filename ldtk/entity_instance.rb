module Hoard
    module Ldtk
        class EntityInstance < Base
            imports :grid, :identifier, :pivot, :smart_color, :tags, :tile, 
                        :world_x, :world_y, :def_uid, :height, 
                        :iid, :px, :width, field_instances: [FieldInstance]

            def field(id)
                field_instances.select { |i| i.identifier == id }.map { |i| i.value }.flatten
            end
        end
    end
end