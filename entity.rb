# https://github.com/deepnight/gameBase/blob/master/src/game/Entity.hx

module Hoard
    class Entity < Process
        include Scriptable

        attr_sprite

        GRID = 16

        ##
        # cx, cy are grid coords
        # xr, yr are ratios 
        # xx, yy are cx,cy + xr,xy
        # dx, dy are change in x, y
        attr :cx, :cy, :xr, :yr

        # world coords
        attr :wx, :wy 

        attr :squash_x, :squash_y, :scale_x, :scale_y
        
        attr :dx_total, :dy_total, :destroyed, :dir, :visible, :dir

        attr :cd, :ucd, :fx
        attr :all_velocities, :v_base, :v_bump

        attr :animation, :animations

        def self.resolve(id)
            resolution = nil

            ObjectSpace.each_object(Class) do |c| 
                if c.name == id 
                    resolution = c  # can't return from here for some reason
                    break
                end
            end

            return resolution
        end

        def initialize(x, y, parent = nil)
            super(parent)

            set_pos_case(x, y)
            @dir = 1
            @w = GRID 
            @h = GRID
            @tile_w = GRID 
            @tile_h = GRID

            @dx = 0
            @dy = 0

            @squash_x = 1
            @squash_y = 1
            @scale_x = 1
            @scale_y = 1
        
            @cd = Cooldown.new
            @ucd = Cooldown.new

            @animation = :idle

            @all_velocities = Phys::VelocityArray.new
            @v_base = register_new_velocity(0.82)
            @v_bump = register_new_velocity(0.93)

            @fx = Fx.new

            @animations = {
                idle: { x: 0, y: 0, frames: 1 }
            }
        end

        def current_animation
            animations[@animation]
        end

        def play_animation(what)
            @animation = what
        end

        def register_new_velocity(frict)
            v = Phys::Velocity.create_frict(frict)
            @all_velocities.push(v)
            v
        end

        def squash_x=(scale)
            @squash_x = scale
            @squash_y = 2 - scale
        end

        def squash_y=(scale)
            @squash_x = 2 - scale 
            @squash_y = scale
        end

        def shake_s(x_pow, y_pow, t)
            cd.set_s("shaking", t, true)
            @shake_pow_x = x_pow
            @shake_pow_y = y_pow
        end

        def set_pos_case(x, y)
            self.cx = x
            self.cy = y
            self.xr = 0.5
            self.yr = 1
        end

        def update_world_pos
            level = Game.s.current_level
            self.wx = self.x + level.world_x
            self.wy = self.y + level.world_y
        end
        
        def x
            xx * GRID
        end

        def wcx 
            (wx / Const::GRID).to_i
        end

        def wcy 
            (wy / Const::GRID).to_i - 1
        end

        def y 
            yy * GRID
        end

        def xx 
            cx + xr
        end 

        def yy 
            cy + yr
        end

        def has_collision(x, y)
            Game.s.current_level&.has_collision(x, y)
        end

        def has_exit?(x, y)
            Game.s.current_level&.outside?(x, y)
        end

        def destroyed?
            destroyed
        end

        def on_pre_step_x
            send_to_scripts(:on_pre_step_x)
        end
    
        def on_pre_step_y
            send_to_scripts(:on_pre_step_y)
        end

        # beginning of frame loop - called before any other entity update loop
        def pre_update
            super
            @tile_x = current_animation.x + (Const::GRID * ((args.state.tick_count / 10).to_i % current_animation.frames) )
            @tile_y = current_animation.y

            send_to_scripts(:pre_update)
            
            # call on_collision on the player
            return if Game.s.player == self
            return unless Geometry.intersect_rect?(Game.s.player, self)
            
            Game.s.player.send_to_scripts(:on_collision, self)
            send_to_scripts(:on_collision, Game.s.player)

            if Game.s.inputs.keyboard.key_down.e
                send_to_scripts(:on_interact, Game.s.player)
            end
        end

        def center_x
            rect_center_point.x - (GRID / 2)
        end

        def center_y 
            rect_center_point.y - GRID - GRID / 2
        end

        def visible? 
            visible
        end

        def tmod 
            1
        end

        # called after pre_update and update
        # usually used for rendering
        def post_update
            super

            self.flip_horizontally = dir < 0
            
            @squash_x += (1 - @squash_x) * [1, 0.2 * tmod].min
            @squash_y += (1 - @squash_y) * [1, 0.2 * tmod].min

            send_to_scripts(:post_update)

            args.outputs[:scene].sprites.push self
        end

        def on_ground?
            !destroyed? && v_base.dy == 0 && yr == 1 && has_collision(cx, cy + 1)
        end  

        def dx_total
            @all_velocities.sum_x
        end

        def dy_total 
            @all_velocities.sum_y
        end

        def ftime 
            $args.state.tick_count 
        end

        def init 
            send_to_scripts(:init)
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
            cd.update(tmod)
            ucd.update(tmod)
            fx.update(tmod)
            update_world_pos

            send_to_scripts(:update)
        end

        def draw_override(ffi_draw)
            tmpX = x 
            tmpY = y 

            if cd.has("shaking")
                tmpX += Math.cos(ftime * 1.1) * shake_pow_x * cd.get_ratio("shaking")
                tmpY += Math.sin(0.3 + ftime * 1.7) * shake_pow_y * cd.get_ratio("shaking")
            end


            ffi_draw.draw_sprite_hash({
                x: tmpX - (GRID / 2),
                y: tmpY.from_top + GRID,
                w: w * @scale_x * @squash_x,
                h: h * @scale_y * @squash_y,
                tile_w: tile_w,
                tile_h: tile_h,
                tile_x: tile_x,
                tile_y: tile_y,
                path: current_animation.path || @path,
                flip_horizontally: flip_horizontally
            })

            @fx.draw_override(ffi_draw)
        end
    end
end