module Hoard
  class Const
    # why isn't this on Scaler
    def self.scale
      Scaler.best_fit_i(1920 * 2, 1080 * 2)
      #Scaler.best_fit_i(300 / 2, 300 / 2)
    end
  end
end
