require_relative "base"
require_relative "definitions"
require_relative "level"
require_relative "world"

module Hoard
    module Ldtk 
        class Root < Base
            imports :bg_color, :external_levels, :iid, :json_version, 
                :toc, :world_grid_height, :world_grid_width,
                :world_layout, worlds: [World], levels: [Level], defs: Definitions

            def free?
                world_layout == "Free"
            end

            def level(**query)
                levels.find do |i|
                    query.any? do |k, v|
                        i.send(k.to_s) == v  
                    end
                end
            end

            def enum(id)
                defs.enums.find { |i| i.identifier == id }
            end

            def tileset(uid)
                defs.tilesets.find { |i| i.uid == uid }
            end

            def entity(uid)
                defs.entities.find { _1.uid == uid }
            end

            def grid_vania?
                world_layout == "GridVania"
            end

            def linear_horizontal?
                world_layout == "LinearHorizontal"
            end

            def linear_vertical
                world_layout == "LinearVertical"
            end
        end
    end
end