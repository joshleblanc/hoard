module Hoard
  class Const
    # why isn't this on Scaler
    def self.scale
      #Scaler.best_fit_i(1920 * 2, 1080 * 2)
      Scaler.best_fit_i(150 * 4, 150 * 4)
    end
  end
end
