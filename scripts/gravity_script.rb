module Hoard
  module Scripts
    class GravityScript < Script
      def initialize(gravity = 0.05)
        @gravity = gravity
      end

      def pre_update
        entity.v_base.dy += @gravity unless entity.on_ground?
      end

      def on_pre_step_y
        return unless entity.yr > 1
        return unless entity.has_collision(entity.cx, entity.cy + 1)

        entity.v_base.dy = 0
        entity.v_bump.dy = 0
        entity.yr = 1

        landing_animation = entity.scripts.find { _1.id == :landing }

        return unless landing_animation

        entity.cd.set("landing", landing_animation.frame_length / 60)
        landing_animation.play!
      end
    end
  end
end
