class Item < Hoard::Entity
    attr :name, :description, :type, :value, :collected

    def initialize(name:, description:, type:, value: 0, **opts)
        super(**opts)
        @name = name
        @description = description
        @type = type
        @value = value
        @collected = false
    end

    def use(target)
        case @type
        when :potion
            heal_amount = @value
            target.entity.rpg_stats_script.hp = [
                target.entity.rpg_stats_script.hp + heal_amount,
                target.entity.rpg_stats_script.max_hp
            ].min
            Game.s.add_message("Used #{@name}, healed #{heal_amount} HP!")
        when :weapon
            target.entity.rpg_stats_script.attack += @value
            Game.s.add_message("Equipped #{@name}, +#{@value} attack!")
        when :armor
            target.entity.rpg_stats_script.defense += @value
            Game.s.add_message("Equipped #{@name}, +#{@value} defense!")
        when :xp_boost
            target.entity.rpg_stats_script.gain_xp(@value)
            Game.s.add_message("Used #{@name}, gained #{@value} XP!")
        end
    end
end
