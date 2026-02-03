class Game < Hoard::Game
    SCREEN_W = 1280
    SCREEN_H = 720

    attr :ui_layer, :game_state, :message_log

    def initialize
        super
        @ui_layer = Layer.new(:ui)
        @message_log = []
        @game_state = :exploring

        setup_game
    end

    def setup_game
        player_entity = Player.new(parent: self, cx: 5, cy: 5)
        user.player = player_entity

        room = Room.new(name: "Forest Clearing", description: "Trees surround you. A path leads east.", grid_w: 10, grid_h: 10, parent: self)
        room.set_wall(0, 0)
        room.set_wall(1, 0)
        room.set_wall(9, 0)
        room.set_wall(0, 9)
        room.set_wall(9, 9)

        slime = Enemy.new(name: "Slime", hp: 30, attack: 8, defense: 2, xp: 25, parent: room)
        slime.set_pos_case(3, 3)
        room.spawn_enemy(slime)

        potion = Item.new(name: "Health Potion", description: "Restores 50 HP", type: :potion, value: 50, parent: room)
        potion.set_pos_case(7, 7)
        room.spawn_item(potion)

        player_entity.enter_room(room)
    end

    def restart
        @message_log.clear
        destroy_all_children!
        @ui_layer.clear
        setup_game
    end

    def add_message(text)
        @message_log << { text: text, tick: args.state.tick_count }
        @message_log.shift if @message_log.length > 8
    end

    def post_update
        args.outputs[:ui].sprites << @ui_layer
        args.outputs[:ui].borders << @ui_layer
        args.outputs[:ui].labels << @ui_layer
    end

    def pre_update
        args.outputs.background_color = [20, 20, 30]
        args.outputs[:ui].transient!
    end

    def render
        player = user.player
        if player&.current_room
            args.outputs.labels << {
                x: 20, y: SCREEN_H - 40,
                text: "Room: #{player.current_room.name}",
                size_enum: 4, r: 200, g: 200, b: 200
            }
        end

        messages_y = SCREEN_H - 100
        @message_log.each_with_index do |msg, i|
            alpha = [(msg[:tick] + 3000 - args.state.tick_count) / 500.0 * 255, 255].min
            next if alpha <= 0
            args.outputs.labels << {
                x: 20, y: messages_y - (i * 25),
                text: "> #{msg[:text]}",
                size_enum: 2, r: 180, g: 180, b: 180, a: alpha
            }
        end

        args.outputs.borders << {
            x: 400, y: 100, w: 2, h: SCREEN_H - 200,
            r: 60, g: 60, b: 60
        }
        args.outputs.borders << {
            x: 900, y: 100, w: 2, h: SCREEN_H - 200,
            r: 60, g: 60, b: 60
        }
    end

    def handle_input(key)
        player = user.player
        return unless player

        case key
        when :up
            player.try_move(0, -1)
        when :down
            player.try_move(0, 1)
        when :left
            player.try_move(-1, 0)
        when :right
            player.try_move(1, 0)
        when :a
            player.attack
        when :i
            player.toggle_inventory
        end
    end

    def update
        inputs = args.inputs
        if inputs.keyboard.key_down.up
            handle_input(:up)
        elsif inputs.keyboard.key_down.down
            handle_input(:down)
        elsif inputs.keyboard.key_down.left
            handle_input(:left)
        elsif inputs.keyboard.key_down.right
            handle_input(:right)
        elsif inputs.keyboard.key_down.a
            handle_input(:a)
        elsif inputs.keyboard.key_down.i
            handle_input(:i)
        end
    end
end
