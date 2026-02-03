class Player < Hoard::Entity
    attr :current_room, :inventory_open

    script Hoard::Scripts::RpgStatsScript.new(
        hp: 100, max_hp: 100, attack: 15, defense: 5, level: 1, xp: 0, xp_to_next: 100
    )
    script Hoard::Scripts::InventoryRpgScript.new
    script Hoard::Scripts::CombatScript.new
    script Hoard::Scripts::DialogueScript.new
    widget StatsWidget.new
    widget InventoryWidget.new

    def initialize(**opts)
        super
        @current_room = nil
        @inventory_open = false
    end

    def enter_room(room)
        @current_room = room
        send_to_scripts(:on_enter_room, room)
        add_message("Entered #{room.name}")
        room.on_enter(self)
    end

    def try_move(dx, dy)
        return if @inventory_open

        new_cx = cx + dx
        new_cy = cy + dy

        if current_room&.can_move_to?(new_cx, new_cy)
            set_pos_case(new_cx, new_cy)
            send_to_scripts(:on_move, dx, dy)
            current_room.check_encounter(self)
        else
            add_message("Blocked!")
        end
    end

    def attack
        send_to_scripts(:on_attack)
    end

    def toggle_inventory
        @inventory_open = !@inventory_open
        entity.inventory_widget.visible = @inventory_open
        add_message(@inventory_open ? "Inventory opened" : "Inventory closed")
    end

    def add_message(text)
        Game.s.add_message(text)
    end
end
