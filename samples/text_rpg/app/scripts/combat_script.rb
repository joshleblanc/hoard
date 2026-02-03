module Hoard
    module Scripts
        class CombatScript < Hoard::Script
            attr_accessor :in_combat, :current_target

            def initialize
                @in_combat = false
                @current_target = nil
                @combat_log = []
            end

            def init
                @widget = entity.stats_widget
            end

            def on_attack
                return unless @in_combat && @current_target

                damage = entity.rpg_stats_script.attack
                @current_target.take_damage(damage)

                if @current_target.alive?
                    @current_target.attack_target(entity)
                else
                    end_combat
                end
            end

            def on_combat_start(enemy)
                @in_combat = true
                @current_target = enemy
                entity.add_message("Combat started with #{enemy.name}!")
            end

            def end_combat
                @in_combat = false
                @current_target = nil
                entity.add_message("Combat ended.")
            end

            def on_move(dx, dy)
                if @in_combat
                    entity.add_message("Cannot flee from combat!")
                    return false
                end
                true
            end

            def post_update
            end
        end
    end
end
