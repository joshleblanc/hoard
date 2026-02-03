require_relative "game"
require_relative "scripts/rpg_stats_script"
require_relative "scripts/combat_script"
require_relative "scripts/dialogue_script"
require_relative "scripts/inventory_rpg_script"
require_relative "widgets/stats_widget"
require_relative "widgets/text_widget"
require_relative "widgets/inventory_widget"
require_relative "entities/player"
require_relative "entities/enemy"
require_relative "entities/room"
require_relative "entities/item"


Hoard.configure do |config|
    config.game_class = Game
end

def tick(args)
    Game.s.args = args
    Game.s.tick
end

def reset(args)
    Game.s.restart
end
