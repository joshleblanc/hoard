module Hoard
    module Phys 
        class VelocityArray < Array
            def remove(v)
                delete(v) 
            end
            
            def dispose 
                # ??
            end

            def sum_x
                sum(&:x)
            end

            def sum_y
                sum(&:y)
            end

            def mul_all(f)
                reduce(0) { |sum, vel| sum + vel.mul(f) }
            end

            def mul_all_x(f)
                reduce(0) { |sum, vel| sum + vel.mul_xy(f, 1) }
            end

            def mul_all_y(f)
                reduce(0) { |sum, vel| sum + vel.mul_xy(1, f) }
            end

            def clear_all
                each(&:clear)
            end

            def remove_zeroes
                reject!(&:zero?)
            end
        end
    end
end