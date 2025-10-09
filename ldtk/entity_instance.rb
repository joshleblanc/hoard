module Hoard
    module Ldtk
        class EntityInstance < Base
            imports :grid, :identifier, :pivot, :smart_color, :tags, :tile, 
                        :world_x, :world_y, :def_uid, :height, 
                        :iid, :px, :width, field_instances: [FieldInstance]

            def field(id)
                field_instances.select { |i| i.iid == id }.map { |i| i.value }.flatten
            end

            def definition
                root.entity(self.def_uid)
            end
        end
    end
end