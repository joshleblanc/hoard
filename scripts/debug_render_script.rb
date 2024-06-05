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

                outputs[:scene].debug << [grid_pos, act_pos]

            end
        end
    end
end
