module Hoard
  module Scripts
    class MoveToNeighbourScript < Script
      def on_pre_step_x
        e = entity
        if e.xr > 0.8
          e.xr = 0.8 if e.has_collision(e.cx + 1, e.cy)
          move_to_neighbour(e.wcx + 1, e.wcy) if e.has_exit?(e.cx + 1, e.cy)
        end

        if e.xr < 0.2
          e.xr = 0.2 if e.has_collision(e.cx - 1, e.cy)
          move_to_neighbour(e.wcx - 1, e.wcy) if e.has_exit?(e.cx - 1, e.cy)
        end
      end

      def on_pre_step_y
        e = entity
        if e.yr >= 1
          move_to_neighbour(e.wcx, e.wcy + 1) if e.has_exit?(e.cx, e.cy + 1)
        end

        if e.yr < 0.2
          move_to_neighbour(e.wcx, e.wcy - 1) if e.has_exit?(e.cx, e.cy - 1)
        end

        if e.yr < 0.2
          if e.has_collision(e.cx, e.cy - 1)
            e.yr = 0.2
          end
        end
      end

      #
      # Move an entity to a new level, given their current world coords
      def move_to_neighbour(wx, wy)
        level = Hoard.config.game_class.s.current_level
        neighbour = level.find_neighbour(wx, wy)

        return unless neighbour

        wcx = (neighbour.world_x / Hoard.config.game_class::GRID)
        wcy = (neighbour.world_y / Hoard.config.game_class::GRID)

        entity.set_pos_case(wx - wcx, wy - wcy)
        Hoard.config.game_class.s.start_level(neighbour)
      end
    end
  end
end
