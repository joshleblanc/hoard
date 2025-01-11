module Hoard
  module Scripts
    class AnimationScript < Script
      attr_reader :id

      def initialize(id, opts = {})
        @id = id
        @opts = opts

        @playing = false
        @loop = false
        @frame = 0

        @offset_x = opts[:offset_x] || 0
        @offset_y = opts[:offset_y] || 0
      end

      def frames
        files ? files.length : @opts.frames
      end

      def files
        @opts.files
      end

      def speed
        @opts.speed || 1
      end

      def speed_ratio
        10 / speed
      end

      def frame_over_speed
        (@frame / speed_ratio)
      end

      def frame_length
        (frames * speed_ratio) + speed_ratio
      end

      def frame
        frame_over_speed.to_i % frames
      end

      def loops
        (frame_over_speed / frames).floor
      end

      def tile_x
        files ? 0 : @opts.x
      end

      def path
        files ? files[frame] : @opts.path
      end

      def tile_y
        files ? 0 : @opts.y
      end

      def play!(should_loop = false, &callback)
        entity.send_to_scripts(:play_animation, id, should_loop, &callback)
      end

      def play_animation(id, should_loop = false, &callback)
        @frame = 0 if id == @id && !playing?

        @playing = id == @id

        return unless playing?

        @loop = should_loop
        @callback = callback
      end

      def loop?
        @loop == true
      end

      def playing?
        @playing == true
      end

      def done?
        return false if loop? # a loop never finishes

        loops > 0 && frame == 0
      end

      def post_update
        return unless playing?

        tmpX = entity.x
        tmpY = entity.y

        if entity.cd.has("shaking")
          tmpX += Math.cos(entity.ftime * 1.1) * entity.shake_pow_x * entity.cd.get_ratio("shaking")
          tmpY += Math.sin(0.3 + entity.ftime * 1.7) * entity.shake_pow_y * entity.cd.get_ratio("shaking")
        end

        offset_scale_x = (entity.w * entity.scale_x) / entity.tile_w
        offset_scale_y = (entity.h * entity.scale_y) / entity.tile_h

        sprite = {
          x: tmpX + -(entity.w / 2) + (@offset_x * offset_scale_x),
          y: tmpY.from_top + entity.h + (@offset_y * offset_scale_y),
          w: entity.w * entity.scale_x * entity.squash_x,
          h: entity.h * entity.scale_y * entity.squash_y,
          tile_w: entity.tile_w,
          tile_h: entity.tile_h,
          tile_x: tile_x,
          tile_y: tile_y,
          path: path,
          flip_horizontally: entity.flip_horizontally,
        }

        outputs[:scene].sprites << sprite if entity.visible?

        @frame = @frame + 1

        if done?
          @playing = false
          @callback.call if @callback
        end
      end
    end
  end
end
