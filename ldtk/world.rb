require_relative "world"

module Hoard
    module Ldtk 
        class World < Base
            imports :identifier, :iid, :world_grid_height, :world_grid_width,
                    :world_layout, levels: [Level]
        end
    end
end
