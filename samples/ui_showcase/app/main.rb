require_relative "game"
require_relative "widgets/showcase_widget"
require_relative "entities/showcase_entity"

Hoard.configure do |config|
  config.game_class = Game
end

def tick(args)
  Game.s.args = args
  Game.s.tick
end

def reset(args)
  $hoard_ui_theme = Hoard::Ui::Theme.new
end
