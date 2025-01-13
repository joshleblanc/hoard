module Hoard
  module Scripts
    class DebugRenderScript < Script
      def post_update
        grid_w = (entity.w / Const::GRID)
        grid_pos = {
          x: (((entity.cx + (grid_w / 2)) - (grid_w / 2).floor) * 16),
          y: (entity.cy * 16).from_top,
          w: entity.w,
          h: entity.h,
          r: 255, g: 0, b: 0,
          primitive_marker: :border,
        }

        act_pos = {
          x: entity.rx,
          y: entity.ry,
          w: entity.rw,
          h: entity.rh,
          r: 0, g: 255, b: 0,
          primitive_marker: :border,
        }

        center_pos = {
          x: entity.center_x,
          y: entity.center_y.from_top,
          w: 1,
          h: 1,
          r: 0, g: 0, b: 255,
          primitive_marker: :solid,
        }

        outputs[:scene].debug << [grid_pos, act_pos, center_pos]
      end
    end
  end
end
