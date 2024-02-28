module Hoard
    module Ldtk
        class TilesetDefinition < Base
            imports :c_hei, :c_wid, :custom_data, :embed_atlas, :enum_tags,
                        :identifier, :padding, :px_hei, :px_wid, :rel_path, :spacing,
                        :tags, :tags_source_enum_uid, :tile_grid_size, :uid 
        end
    end
end