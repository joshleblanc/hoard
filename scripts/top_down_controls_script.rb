module Hoard
  module Scripts
    class TopDownControlsScript < Script
      def initialize(move_speed: 0.6)
        @move_speed = move_speed
        @current_dx = 0
        @current_dy = 0
        @last_dir = :down
      end

      def pre_update
        @current_dx = 0
        @current_dy = 0
        was_moving = @current_dx != 0 || @current_dy != 0

        inputs = Hoard.config.game_class.s.inputs.keyboard

        if inputs.key_held.left && !entity.cd.has("controls_disabled")
          @current_dx = -@move_speed
          entity.send_to_scripts(:play_animation, :walk_left)
          entity.send_to_scripts(:play_audio, :footsteps)
          entity.dir = -1
          @last_dir = :left
        elsif inputs.key_held.right && !entity.cd.has("controls_disabled")
          @current_dx = @move_speed
          entity.send_to_scripts(:play_animation, :walk_right)
          entity.send_to_scripts(:play_audio, :footsteps)
          entity.dir = 1
          @last_dir = :right
        end

        if inputs.key_held.up && !entity.cd.has("controls_disabled")
          @current_dy = -@move_speed
          entity.send_to_scripts(:play_animation, :walk_up)
          entity.send_to_scripts(:play_audio, :footsteps)
          @last_dir = :up
        elsif inputs.key_held.down && !entity.cd.has("controls_disabled")
          entity.send_to_scripts(:play_animation, :walk_down)
          entity.send_to_scripts(:play_audio, :footsteps)
          @current_dy = @move_speed
          @last_dir = :down
        end

        unless @current_dx != 0 || @current_dy != 0
          if @last_dir
            entity.send_to_scripts(:play_animation, "idle_#{@last_dir}".to_sym)
          else
            entity.send_to_scripts(:play_animation, :idle_down)
          end
        end
      end

      def update
        entity.v_base.dx = @current_dx
        entity.v_base.dy = @current_dy
      end

      def on_pre_step_x
        e = entity
        # Handle horizontal collisions
        if e.xr > 0.8
          e.xr = 0.8 if e.has_collision(e.cx + 1, e.cy)
        end

        if e.xr < 0.2
          e.xr = 0.2 if e.has_collision(e.cx - 1, e.cy)
        end
      end

      def on_pre_step_y
        e = entity
        # Handle vertical collisions
        if e.yr > 0.8
          e.yr = 0.8 if e.has_collision(e.cx, e.cy + 1)
        end

        if e.yr < 0.2
          e.yr = 0.2 if e.has_collision(e.cx, e.cy - 1)
        end
      end
    end
  end
end
