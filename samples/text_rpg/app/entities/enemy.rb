class Enemy < Hoard::Entity
    attr :name, :alive

    script Hoard::Scripts::RpgStatsScript.new

    def initialize(name:, hp:, attack:, defense:, xp:, **opts)
        super(**opts)
        @name = name
        @alive = true
        @_initial_hp = hp

        entity.rpg_stats_script.hp = hp
        entity.rpg_stats_script.max_hp = hp
        entity.rpg_stats_script.attack = attack
        entity.rpg_stats_script.defense = defense
        entity.rpg_stats_script.xp_reward = xp
    end

    def take_damage(amount)
        actual = [1, amount - entity.rpg_stats_script.defense].max
        entity.rpg_stats_script.hp -= actual
        add_message("#{@name} takes #{actual} damage! HP: #{entity.rpg_stats_script.hp}/#{entity.rpg_stats_script.max_hp}")

        if entity.rpg_stats_script.hp <= 0
            die
        end
    end

    def attack_target(target)
        return unless @alive && target

        damage = entity.rpg_stats_script.attack
        target.entity.rpg_stats_script.hp -= damage
        add_message("#{@name} attacks #{target} for #{damage} damage!")

        if target.entity.rpg_stats_script.hp <= 0
            target.entity.rpg_stats_script.hp = 0
            add_message("#{target} has been defeated!")
        end
    end

    def die
        @alive = false
        add_message("#{@name} defeated! +#{entity.rpg_stats_script.xp_reward} XP")
        destroy
    end

    def add_message(text)
        Game.s.add_message(text)
    end
end
