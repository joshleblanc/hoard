require_relative "game"
require_relative "widgets/health_widget"
require_relative "widgets/coins_widget"
require_relative "scripts/coins_script"
require_relative "scripts/teleport_script"
require_relative "scripts/buyable_script"
require_relative "entities/user"
require_relative "entities/coin"
require_relative "entities/player"
require_relative "entities/teleport"
require_relative "entities/worm"
require_relative "entities/buyable"
require_relative "entities/quests"

Hoard.configure do |config|
    config.game_class = Game
end

def tick(args)
    Game.s.args = args 
    Game.s.tick
end

def reset(args)
    Game.s.auto_start_first_level(true)
    GTK.reset_sprites directory: "samples/platformer/sprites"
end