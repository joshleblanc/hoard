module Hoard
  module Scripts
    class PromptScript < Script
      attr :prompt

      def initialize(prompt: "")
        @prompt = prompt
        @active = true
      end

      def disable!
        @active = false
      end

      def enable!
        @active = true
      end

      def active?
        @active
      end

      def on_collision(player)
        return unless active?

        outputs[:ui].labels << {
          x: Hoard.config.game_class.s.camera.level_to_global_x(entity.x),
          y: entity.y,
          text: prompt,
          font_size: 1,
          alignment_enum: 1,
          r: 255, g: 255, b: 255, a: 255,
        }
      end
    end
  end
end
