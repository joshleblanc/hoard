class Room < Hoard::Entity
    attr :name, :description, :grid_w, :grid_h
    attr :tiles, :enemies, :items

    def initialize(name:, description:, grid_w: 10, grid_h: 10, **opts)
        super(**opts)
        @name = name
        @description = description
        @grid_w = grid_w
        @grid_h = grid_h
        @tiles = Array.new(grid_w) { Array.new(grid_h) { :floor } }
        @enemies = []
        @items = []
        @entities = []

        setup_room
    end

    def setup_room
        set_pos_case(0, 0)
    end

    def can_move_to?(x, y)
        return false if x < 0 || x >= @grid_w || y < 0 || y >= @grid_h
        @tiles[x][y] == :floor
    end

    def set_wall(x, y)
        @tiles[x][y] = :wall if x >= 0 && x < @grid_w && y >= 0 && y < @grid_h
    end

    def set_floor(x, y)
        @tiles[x][y] = :floor if x >= 0 && x < @grid_w && y >= 0 && y < @grid_h
    end

    def spawn_enemy(enemy)
        @enemies << enemy
        enemy.parent = self
        enemy.set_pos_case(cx + rand(1..@grid_w - 2), cy + rand(1..@grid_h - 2))
    end

    def spawn_item(item)
        @items << item
        item.parent = self
        item.set_pos_case(cx + rand(1..@grid_w - 2), cy + rand(1..@grid_h - 2))
    end

    def check_encounter(player)
        enemy = @enemies.find { |e| e.alive && e.cx == player.cx && e.cy == player.cy }
        if enemy
            add_message("Encountered #{enemy.name}!")
            player.entity.send_to_scripts(:on_combat_start, enemy)
        end

        item = @items.find { |i| !i.collected && i.cx == player.cx && i.cy == player.cy }
        if item
            add_message("Found #{item.name}!")
            player.entity.inventory_rpg_script.add_item(item)
            item.collected = true
        end
    end

    def on_enter(player)
        @enemies.each { |e| e.alive = true }
        @items.each { |i| i.collected = false }
    end

    def add_message(text)
        Game.s.add_message(text)
    end

    def post_update
        @enemies.each(&:post_update)
        @items.each(&:post_update)
    end

    def update
        @enemies.each(&:update)
        @items.each(&:update)
    end
end
