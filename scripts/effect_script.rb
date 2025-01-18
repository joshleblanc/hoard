module Hoard
  module Scripts
    class EffectScript < Script
      def initialize(id, data)
        @id = id
        @data = data
      end

      def play_effect(id, x, y)
        return unless @id == id
        Game.s.fx.anim({
          x: x,
          y: y,
          **@data,
        })
      end
    end
  end
end
