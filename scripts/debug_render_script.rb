module Hoard
    module Scripts 
        class DebugRenderScript < Script 
            def post_update 
                grid_pos = {
                    x: entity.cx * 16,
                    y: (entity.cy * 16).from_top,
                    w: 16,
                    h: 16,
                    r: 255, g: 0, b: 0,
                    primitive_marker: :border
                }

                act_pos = {
                    x: entity.x - (entity.w / 2),
                    y: entity.y.from_top + entity.h,
                    w: 16,
                    h: 16,
                    r: 0, g: 255, b: 0,
                    primitive_marker: :border
                }

                center_pos = {
                    x: entity.center_x,
                    y: entity.center_y.from_top,
                    w: 1,
                    h: 1,
                    r: 0, g: 0, b: 255,
                    primitive_marker: :solid
                }

                outputs[:scene].debug << [grid_pos, act_pos, center_pos]

            end
        end
    end
end
