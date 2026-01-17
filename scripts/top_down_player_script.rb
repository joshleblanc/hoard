module Hoard
  module Scripts
    class TopDownPlayerScript < Script
      attr_accessor :walk_speed, :health

      def initialize(**options)
        super()
        @walk_speed = options[:walk_speed] || 0.6
        @health = options[:health] || 3
      end

      def init
        # Add all the common top-down RPG scripts
        entity.add_script LdtkEntityScript.new
        entity.add_script SaveDataScript.new
        entity.add_script TopDownControlsScript.new(move_speed: @walk_speed)
        entity.add_script HealthScript.new(health: @health)
        entity.add_script NotificationsScript.new
        entity.add_script MoveToNeighbourScript.new

        # Auto-track camera on player
        Hoard.config.game_class.s.camera.track_entity(entity, false)
        Hoard.config.game_class.s.camera.clamp_to_level_bounds = true

        # Set velocity friction for smoother top-down movement
        entity.v_base.set_fricts(0.9, 0.9)
      end
    end
  end
end
