module Hoard
  module Scripts
    class PlatformerPlayerScript < Script
      attr_accessor :walk_speed, :gravity, :jumps, :jump_power, :health

      def initialize(**options)
        super()
        @walk_speed = options[:walk_speed] || 0.6
        @gravity = options[:gravity] || 0.025
        @jumps = options[:jumps] || 2
        @jump_power = options[:jump_power] || 0.45
        @health = options[:health] || 3
      end

      def init
        # Add all the common platformer scripts
        entity.add_script LdtkEntityScript.new
        entity.add_script SaveDataScript.new
        entity.add_script GravityScript.new(@gravity)
        entity.add_script PlatformerControlsScript.new
        entity.add_script JumpScript.new(jumps: @jumps, power: @jump_power)
        entity.add_script HealthScript.new(health: @health)
        entity.add_script NotificationsScript.new

        # Auto-track camera on player with vertical offset for better visibility
        ::Game.s.camera.track_entity(entity, true)
        ::Game.s.camera.clamp_to_level_bounds = true

        # Set velocity friction for platformer feel
        entity.v_base.set_fricts(0.84, 0.94)
      end
    end
  end
end
