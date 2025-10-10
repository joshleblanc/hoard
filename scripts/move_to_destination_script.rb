class MoveToDestinationScript < Hoard::Script 
    attr :destination, :loop
    
    def init 
        entity.move_towards(destination.cx * Hoard.config.game_class::GRID, destination.cy * Hoard.config.game_class::GRID)
    end
end