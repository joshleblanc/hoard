module Hoard
  module Scripts
    class PlatformerControlsScript < Script
      def initialize(move_speed: 1)
        @move_speed = move_speed
        @current_speed = 0
      end

      def pre_update
        @previous_speed = @current_speed
        @current_speed = 0

        if ::Game.s.inputs.keyboard.key_held.left && !entity.cd.has("controls_disabled")
          @current_speed = -@move_speed
          entity.dir = -1
          entity.send_to_scripts(:play_animation, :walk) if entity.on_ground?
          entity.send_to_scripts(:play_audio, :footsteps)
        elsif ::Game.s.inputs.keyboard.key_held.right && !entity.cd.has("controls_disabled")
          @current_speed = @move_speed
          entity.dir = 1

          entity.send_to_scripts(:play_animation, :walk) if entity.on_ground?
          entity.send_to_scripts(:play_audio, :footsteps)
        else
          entity.send_to_scripts(:play_animation, :idle) if entity.on_ground? && !entity.cd.has("landing")
        end

        if ::Game.s.inputs.keyboard.key_held.up && !entity.cd.has("controls_disabled")
          @current_speed = 0
          if ::Game.s.current_level.layer("Collisions").int(entity.cx, entity.cy) == 2 # ladder
            entity.v_base.dy = -0.2
          end
        end
      end

      def update
        if @current_speed == 0 && @previous_speed != 0
          entity.send_to_scripts(:play_effect, :skid, {
            x: entity.rx,
            y: entity.ry + (entity.rh * entity.anchor_y),
            flip_horizontally: entity.dir == -1,
            speed: 8,
          })
        end
        entity.v_base.dx = (entity.v_base.dx + @current_speed) * 0.085 if @current_speed != 0
      end
    end
  end
end
