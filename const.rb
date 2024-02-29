module Hoard
    class Const 
        GRID = 16
        
        # why isn't this on Scaler
        def self.scale 
            Scaler.best_fit_i(300, 300)
        end
    end
end