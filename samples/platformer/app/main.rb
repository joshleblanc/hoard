require_relative "game"
require_relative "widgets/coins_widget"
require_relative "scripts/coins_script"
require_relative "entities/user"
require_relative "entities/coin"
require_relative "entities/player"

def tick(args)
    Game.s.args = args 
    Game.s.tick
end