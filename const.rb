module Hoard
    class Const 
        GRID = 16
        
        # why isn't this on Scaler
        def self.scale 
            puts "Scale: #{Scaler.best_fit_i(200, 200)}"
            Scaler.best_fit_i(200, 200)
        end
    end
end