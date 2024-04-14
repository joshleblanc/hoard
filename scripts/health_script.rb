module Hoard 
    module Scripts 
        class HealthScript < Script 
            attr :life, :last_dmg_source, :last_hit_dir_from_source, :last_hit_dir_to_source

            def initialize(health: 1)
                @life = Stat.new
                @life.init_max_on_max(health)
            end

            def on_damage(amt, from = nil)
                return if amt <= 0
                return if dead?

                @life.v -= amt
                @last_dmg_source = from

                if @life.v <= 0 
                    entity.send_to_scripts(:on_die)
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