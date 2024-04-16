module Hoard 
    class Stat
        attr :v, :max, :min

        def initialize
            init(0, 0, 0)
        end

        def init(value, max_or_min, max = nil)
            if max == nil 
                self.max = max_or_min
                self.v = value
            else 
                self.max = max
                self.min = max_or_min
                self.v = value
            end
        end

        def reset!
            self.v = self.max
        end

        def init_max_on_max(max)
            init(max, 0, max)
        end
    end
end