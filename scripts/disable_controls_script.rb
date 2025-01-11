module Hoard
  module Scripts
    class DisableControlsScript < Script
      def on_damage(amt, from = nil)
        disable_controls!(3)
      end

      def disable_controls!(duration = 1.0)
        p "Disabling controls"
        entity.cd.set_s("controls_disabled", duration)
      end
    end
  end
end
