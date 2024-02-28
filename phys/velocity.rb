# https://github.com/deepnight/deepnightLibs/blob/master/src/dn/phys/Velocity.hx

module Hoard
    module Phys 
        class Velocity 
            CLEAR_THRESHOLD = 0.0005

            attr :id, :x, :y, :frict_x, :frict_y

            def initialize
                self.id = -1 
                self.x = 0
                self.y = 0
                self.frict = 0
            end

            def self.create_init(x, y, frict = 1.0)
                new.tap do |v|
                    v.set(x, y)
                    v.frict = frict
                end
            end

            def self.create_frict(frict)
                new.tap do |v|
                    v.frict = frict
                end
            end

            def v 
                x
            end

            def to_s 
                "Velocity#{id < 0 ? "" : "#" + id }(#{ short_string })"
            end

            def short_string 
                "#{x},#{y}"
            end

            def v=(new_v)
                self.x = new_v
                self.y = new_v
            end

            def set_fricts(fx, fy)
                self.frict_x = fx
                self.frict_y = fy
            end

            def mul_xy(fx, fy)
                self.x = x * fx
                self.y = y * fy
            end

            def mul(f) 
                self.x = x * f
                self.y = y * f 
            end

            def *(f)
                mul(f)
            end

            def clear 
                self.x = 0
                self.y = 0
            end 

            def add_xy(vx, vy)
                self.x += vx
                self.y += vy
            end

            def add_len(v)
                l = len
                a = ang 
                self.x = Math.cos(a) * (l + v)
                self.y = Math.sin(a) * (l + v)
            end

            def set(x, y)
                self.x = x
                self.y = y
            end

            def set_both(v)
                self.x = v 
                self.y = v
            end

            def add_ang(ang, v)
                self.x += Math.cos(ang) * v
                self.y += Math.sin(ang) * v
            end

            def set_ang(ang, v)
                self.x = Math.cos(ang) * v
                self.y = Math.sin(ang) * v
            end

            def rotate(ang_inc)
                oldAng = ang 
                d = len

                self.x = Math.cos(oldAng + angInc) * d
                self.y = Math.sin(oldAng + angInc) * d 
            end

            def zero?
                x.abs <= CLEAR_THRESHOLD && y.abs <= CLEAR_THRESHOLD
            end

            def update(frict_override = -1.0)
                if frict_override >= 0
                    self.x = x * frict_override
                    self.y = y * frict_override
                else 
                    self.x = x * frict_x
                    self.y = y * frict_y
                end

                self.x = 0 if x.abs < CLEAR_THRESHOLD
                self.y = 0 if y.abs < CLEAR_THRESHOLD
            end
            
            def dx 
                x 
            end

            def dy
                y
            end
            
            def dx=(new_x)
                self.x = new_x
            end

            def dy=(new_y)
                self.y = new_y
            end

            def frict=(new_frict)
                self.frict_x = new_frict 
                self.frict_y = new_frict
            end

            def ang
                Math.atan2(y, x)
            end

            def len
                Math.sqrt(x*x, y*y)
            end

            def dir_x 
                if x == 0 
                    0 
                elsif x > 0
                    1
                else 
                    -1
                end
            end

            def dir_y
                if x == 0 
                    0 
                elsif x > 0
                    1
                else 
                    -1
                end
            end
        end
    end
end