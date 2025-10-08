module Hoard
  module Scripts
    class EffectScript < Script
      def initialize(id, data)
        @id = id
        @data = data
      end

      def play_effect(id, opts = {})
        return unless @id == id
        ::Game.s.fx.anim({
          **opts,
          x: opts[:x] || entity.rx,
          y: opts[:y] || entity.ry,
          **@data,
        })
      end
    end
  end
end
