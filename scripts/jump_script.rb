module Hoard
  module Scripts
    class JumpScript < Hoard::Script
      def initialize(jumps: 1, power: 1)
        @jumps = jumps
        @jumps_remaining = jumps
        @power = power
      end

      def can_jump?
        entity.cd.has("recentlyOnGround") || @jumps_remaining > 0
      end

      def update
        if entity.on_ground?
          @jumps_remaining = @jumps
          entity.cd.set_s("recentlyOnGround", 0.1)
        end

        if can_jump? && Game.s.inputs.keyboard.key_down.space
          entity.v_base.dy = -@power
          entity.squash_x = 0.6
          entity.cd.unset("recentlyOnGround")

          @jumps_remaining -= 1

          Game.s.fx.anim({
            path: "sprites/effects.png",
            x: entity.center_x,
            y: entity.center_y,
            tile_w: 64,
            tile_h: 64,
            tile_x: 0,
            tile_y: 11 * 64,
            frames: 11,
          })

          if entity.v_base.dx == 0
            entity.send_to_scripts(:play_animation, :standing_jump, true)
          else
            entity.send_to_scripts(:play_animation, :moving_jump, true)
          end
        end
      end
    end
  end
end
