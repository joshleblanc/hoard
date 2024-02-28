module Hoard
    module Ldtk 
        class LayerDefinition < Base
            imports :type, :auto_source_layer_def_uid, :display_opacity, :grid_size,
                        :identifier, :int_grid_values, :int_grid_values_groups, :parallax_factor_x,
                        :parallax_factor_y, :parallax_scaling, :px_offset_x, :px_offset_y,
                        :tileset_def_uid, :uid, :auto_tileset_def_uid
        end
    end
end