require_relative "game"
require_relative "entities/coin"
require_relative "entities/player"

def tick(args)
    Game.s.args = args 
    Game.s.tick
end