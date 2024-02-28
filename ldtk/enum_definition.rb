require_relative "enum_value_definition"

module Hoard
    module Ldtk
        class EnumDefinition < Base
            imports :external_rel_path, :icon_tileset_uid, :identifier,
                        :tags, :uid, values: [EnumValueDefinition]
        end
    end
end