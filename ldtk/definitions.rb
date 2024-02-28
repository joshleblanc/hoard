require_relative "entity_definition"
require_relative "enum_definition"
require_relative "layer_definition"
require_relative "field_definition"
require_relative "tileset_definition"

module Hoard
    module Ldtk
        class Definitions < Base
            imports entities: [EntityDefinition],
                    enums: [EnumDefinition],
                    external_enums: [EnumDefinition],
                    layers: [LayerDefinition],
                    level_fields: [FieldDefinition],
                    tilesets: [TilesetDefinition]
        end
    end
end
