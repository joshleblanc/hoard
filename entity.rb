# https://github.com/deepnight/gameBase/blob/master/src/game/Entity.hx

module Hoard
    class Entity 
        attr_sprite

        GRID = 16


        ##
        # cx, cy are grid coords
        # xr, yr are ratios 
        # xx, yy are cx,cy + xr,xy
        # dx, dy are change in x, y
        attr :cx, :cy, :xr, :yr, :xx, :yy
        
        attr :dx_total, :dy_total, :destroyed, :dir, :visible, :dir

        attr :cd, :ucd
        attr :all_velocities, :v_base, :v_bump

        def initialize(x, y)
            set_pos_case(x, y)
            @dir = 1
            @w = GRID 
            @h = GRID
            @tile_w = GRID 
            @tile_h = GRID

            @dx = 0
            @dy = 0

            @cd = Cooldown.new
            @ucd = Cooldown.new

            @all_velocities = Phys::VelocityArray.new
            @v_base = register_new_velocity(0.82)
            @v_bump = register_new_velocity(0.93)
        end

        def register_new_velocity(frict)
            v = Phys::Velocity.create_frict(frict)
            @all_velocities.push(v)
            v
        end

        def set_pos_case(x, y)
            self.cx = x
            self.cy = y
            self.xr = 0.5
            self.yr = 1
        end

        def x
            (cx + xr) * GRID
        end

        def y 
            (cy + yr) * GRID
        end

        def has_collision(x, y)
            Game.s.current_level&.has_collision(x, y)
        end

        def destroyed?
            destroyed
        end

        def on_pre_step_x 

        end

        def on_pre_step_y 
            
        end

        # beginning of frame loop - called before any other entity update loop
        def pre_update 

        end

        def center_x
            puts "#{rect_center_point.x}, #{x}" 
            rect_center_point.x
        end

        def center_y 
            rect_center_point.y
        end

        def visible? 
            visible
        end

        # called after pre_update and update
        # usually used for rendering
        def post_update 
            self.flip_horizontally = dir < 1
        end

        def final_update

        end

        def dx_total
            @all_velocities.sum_x
        end

        def dy_total 
            @all_velocities.sum_y
        end

        # I'm not going to pretend to know what this does
        def update 
            steps = ((dx_total.abs + dy_total.abs) / 0.33).ceil

            if steps > 0 
                n = 0
                while(n < steps) 
                    self.xr += dx_total / steps
                    on_pre_step_x if dx_total != 0 
                    
                    while xr > 1 do 
                        self.xr -= 1
                        self.cx += 1
                    end

                    while xr < 0 do 
                        self.xr += 1
                        self.cx -= 1
                    end

                    self.yr += dy_total / steps 

                    on_pre_step_y if dy_total != 0 

                    while yr > 1 do 
                        self.yr -= 1
                        self.cy += 1
                    end

                    while yr < 0 do 
                        self.yr += 1
                        self.cy -= 1
                    end

                    n += 1
                end
            end

            all_velocities.each(&:update)
        end

        def render
            {
                x: x,
                y: Game.s.grid.h - y + GRID,
                w: w,
                h: h,
                tile_w: tile_w,
                tile_h: tile_h,
                tile_x: tile_x,
                tile_y: tile_y,
                path: path
            }
        end
    end
end