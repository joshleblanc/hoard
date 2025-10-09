module Hoard
    class LPoint 

        attr :cx, :cy, :yr, :xr

        def initialize 
            @cx = 0
            @cy = 0
            @yr = 0
            @xr = 0
        end

        def cxf
            cx + xr
        end

        def cyf
            cy + yr
        end

        def level_x
            cxf * Hoard.config.game_class::GRID
        end

        def level_x=(v)
            set_level_pixel_x(v)
        end

        def level_y
            cyf * Hoard.config.game_class::GRID
        end

        def level_y=(v)
            set_level_pixel_y(v)
        end

        def level_x_i
            level_x.to_i
        end

        def level_y_i 
            level_y.to_i
        end

        def screen_x 
            level_x * Hoard.config.game_class::SCALE + Hoard.config.game_class.s.scroller.x
        end

        def screen_y
            level_y * Hoard.config.game_class::SCALE + Hoard.config.game_class.s.scroller.y
        end

        def self.from_case(cx, cy)
            new.set_level_case(cx.to_i, cy.to_i, cx % 1, cy % 1)
        end

        def self.from_case_center(cx, cy)
            new.set_level_case(cx, cy, 0.5, 0.5)
        end

        def self.from_pixels(x, y)
            new.set_level_pixel(x, y)
        end

        def self.from_screen(sx, sy)
            new.set_screen(sx, sy)
        end

        def set_level_case(x, y, xr = 0.5, yr = 0.5)
            self.cx = x
            self.cy = y
            self.xr = xr
            self.yr = yr
            self
        end

        def use_point(other)
            self.cx = other.cx
            self.cy = other.cy
            self.xr = other.xr
            self.yr = other.yr
        end

        def set_screen(sx, sy)
            set_level_pixel(
                ( sx - Hoard.config.game_class.s.scroller.x ) / Hoard.config.game_class::SCALE,
                ( sy - Hoard.config.game_class.s.scroller.y ) / Hoard.config.game_class::SCALE
            )
            self
        end

        def set_level_pixel(x, y)
            set_level_pixel_x(x)
            set_level_pixel_y(y)
            self
        end

        def set_level_pixel_x(x)
            self.cx = (x / Hoard.config.game_class::GRID).to_i
            self.xr = (x % Hoard.config.game_class::GRID) / Hoard.config.game_class::GRID
            self
        end

        def set_level_pixel_y(y)
            self.cy = (y / Hoard.config.game_class::GRID).to_i
            self.yr = (y % Hoard.config.game_class::GRID) / Hoard.config.game_class::GRID
            self
        end

        def dist_case(a = 0.0, b = 0.0, c = 0.5, d = 0.5)
            if a.is_a? Entity
                Geometry.distance([cx + xr, cy + yr], [a.cx + a.xr, a.cy + a.yr])
            elsif a.is_a? LPoint
                Geometry.distance([cx + xr, cy + yr], [a.cx + a.xr, a.cy + a.yr])
            else 
                Geometry.distance([cs + xr, cy + yr], [a + c, b + d])
            end
        end

        def dist_px(a = 0.0, b = 0.0)
            if a.is_a? Entity
                Geometry.distance([level_x, level_y], [a.attach_x, a.attach_y])
            elsif a.is_a? LPoint
                Geometry.distance([level_x, level_y], [a.level_x, a.level_y])
            else
                Geometry.distance([level_x, level_y], [a, b])
            end
        end

        def ang_to(a, b = nil)
            if a.is_a? Entity
                Math.atan2((a.cy + a.yr) - cyf, (a.cx + a.xr) - cxf)
            elsif a.is_a? LPoint
                Math.atan2(a.cyf - cyf, a.cxf - cxf)
            else 
                Math.atan2(b - level_y, a - level_x)
            end
        end
    end 
end