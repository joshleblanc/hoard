module Hoard
  module Scripts
    class DebugRenderScript < Script
      def post_update
        # Draw entity debug info
        grid_w = (entity.w / Const::GRID)
        grid_pos = {
          x: entity.cx * Const::GRID,
          y: entity.cy * Const::GRID,
          w: Const::GRID,
          h: Const::GRID,
          r: 255, g: 0, b: 0,
          primitive_marker: :border,
        }

        act_pos = {
          x: entity.rx,
          y: entity.ry,
          w: entity.rw,
          h: entity.rh,
          r: 0, g: 255, b: 0,
          anchor_x: entity.anchor_x,
          anchor_y: entity.anchor_y,
          primitive_marker: :border,
        }

        anchor_pos = {
          x: entity.rx,
          y: entity.ry,
          w: 1,
          h: 1,
          anchor_x: 0.5,
          anchor_y: 0.5,
          r: 255, g: 0, b: 255,
          primitive_marker: :solid,
        }

        center_pos = {
          x: entity.center_x,
          y: entity.center_y,
          w: 1,
          h: 1,
          r: 0, g: 0, b: 255,
          anchor_x: entity.anchor_x,
          anchor_y: entity.anchor_y,
          primitive_marker: :solid,
        }

        collisions = {
          x: entity.x,
          y: entity.y,
          w: entity.w,
          h: entity.h,
          r: 0, g: 255, b: 0,
          anchor_x: entity.anchor_x,
          anchor_y: entity.anchor_y,
          primitive_marker: :solid,
          flip_vertically: true,
        }

        outputs[:scene].debug << [grid_pos, act_pos, center_pos, anchor_pos]
        outputs.debug << collisions
      end
    end
  end
end
