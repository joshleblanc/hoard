class Game < Hoard::Game
  GRID = 16
  SCALE = 1

  def initialize
    super
    # No LDtk map -- just spawn the showcase entity directly
    @showcase = ShowcaseEntity.new(parent: self, cx: 0, cy: 0)
  end
end
