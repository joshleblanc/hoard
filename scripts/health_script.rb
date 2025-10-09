module Hoard
  module Scripts
    class HealthScript < Script
      attr :life, :last_dmg_source, :last_hit_dir_from_source, :last_hit_dir_to_source

      def initialize(health: 1, bounce: true)
        @life = Stat.new
        @life.init_max_on_max(health)
        @bounce = bounce
      end

      def reset!
        @life.reset!
      end

      def flash!
        delay = 0.25 * 60

        Scheduler.schedule do |s, blk|
          if entity.cd.has("invulnerability")
            entity.visible = !entity.visible
            s.wait(delay, &blk)
          else
            entity.visible = true
          end
        end
      end

      def ricochet!(target)
        return unless @bounce
        powaaa = 0.5
        upward_force = 0.3
        normal = Geometry.vec2_normalize({ x: entity.x - target.x, y: entity.y.to_f - target.y.to_f })
        entity.v_base.y = powaaa * normal.y - upward_force
        entity.v_base.x = powaaa * normal.x
      end

      def on_damage(amt, from = nil)
        return if amt <= 0
        return if dead?

        return if entity.cd.has("invulnerability")

        entity.cd.set_s("invulnerability", 3)

        flash!
        ricochet!(from)

        @life.v -= amt
        @last_dmg_source = from

        if @life.v <= 0
          entity.send_to_scripts(:on_die)
        end
      end

      def apply_damage(amount, source)
        return if @life.v <= 0
        @last_dmg_source = source
        @last_hit_dir_from_source = Geometry.vec2_normalize({ x: entity.x - source.x, y: entity.y - source.y })
        @last_hit_dir_to_source = Geometry.vec2_normalize({ x: source.x - entity.x, y: source.y - entity.y })
        @life.v -= amount
        ricochet!(source)

        if @life.v <= 0
          if entity.is_a?(Entities::Player)
            Hoard.config.game_class.s.player_died
          elsif entity.is_a?(Entities::Boss)
            Hoard.config.game_class.s.boss_died
          end
        end
      end

      def alive?
        @life.v > 0
      end

      def dead?
        !alive?
      end
    end
  end
end
