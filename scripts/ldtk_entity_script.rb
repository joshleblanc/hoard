module Hoard
  module Scripts
    class LdtkEntityScript < Hoard::Script
      attr :ldtk_entity, :ldtk_id

      def init
        definition = ldtk_entity&.definition
        return unless definition

        rect = definition.tile_rect

        return unless rect

        entity.add_script Hoard::Scripts::AnimationScript.new(
          :ldtk_default_visual,
          path: definition.tileset.rel_path.gsub("../", ""),
          x: rect.x,
          y: rect.y,
          frames: 1,
        )

        entity.send_to_scripts :play_animation, :ldtk_default_visual, true
      end

      def id
        ldtk_entity.iid
      end

      def update
        animations = entity.find_scripts Hoard::Scripts::AnimationScript
        #puts animations
      end
    end
  end
end
