module Hoard
    module Scripts
        class RpgStatsScript < Hoard::Script
            attr_accessor :hp, :max_hp, :attack, :defense, :level, :xp, :xp_to_next, :xp_reward

            def initialize(hp: 50, max_hp: 50, attack: 10, defense: 5, level: 1, xp: 0, xp_to_next: 100, xp_reward: 0)
                @hp = hp
                @max_hp = max_hp
                @attack = attack
                @defense = defense
                @level = level
                @xp = xp
                @xp_to_next = xp_to_next
                @xp_reward = xp_reward
            end

            def init
                @widget = entity.stats_widget
                update_widget
            end

            def on_damage(amount, from = nil)
                actual = [@defense, 1].max
                @hp -= [1, amount - actual].max
                update_widget

                if @hp <= 0
                    entity.add_message("#{entity_name} has been defeated!")
                    entity.destroy if entity.respond_to?(:destroy)
                end
            end

            def on_heal(amount)
                @hp = [@hp + amount, @max_hp].min
                update_widget
            end

            def gain_xp(amount)
                @xp += amount
                entity.add_message("Gained #{amount} XP!")

                while @xp >= @xp_to_next
                    level_up
                end
                update_widget
            end

            def level_up
                @xp -= @xp_to_next
                @level += 1
                @xp_to_next = (@xp_to_next * 1.5).to_i
                @max_hp += 20
                @hp = @max_hp
                @attack += 3
                @defense += 1
                entity.add_message("Leveled up to #{@level}! Max HP: #{@max_hp}, Attack: #{@attack}")
            end

            def entity_name
                return "You" if entity.is_a?(Player)
                entity.name || entity.class.name
            end

            def post_update
                update_widget
            end

            def update_widget
                return unless @widget

                @widget.stats = {
                    hp: @hp,
                    max_hp: @max_hp,
                    attack: @attack,
                    defense: @defense,
                    level: @level,
                    xp: @xp,
                    xp_to_next: @xp_to_next
                }
            end

            def to_h
                {
                    hp: @hp,
                    max_hp: @max_hp,
                    attack: @attack,
                    defense: @defense,
                    level: @level,
                    xp: @xp,
                    xp_to_next: @xp_to_next
                }
            end
        end
    end
end
