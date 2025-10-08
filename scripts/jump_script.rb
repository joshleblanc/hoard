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

        if can_jump? && ::Game.s.inputs.keyboard.key_down.space
          entity.v_base.dy = -@power
          entity.squash_x = 0.6
          entity.cd.unset("recentlyOnGround")

          @jumps_remaining -= 1

          entity.send_to_scripts(:play_effect, :jump_effect, {
            x: entity.rx,
            y: entity.ry + (entity.rh * entity.anchor_y),
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
