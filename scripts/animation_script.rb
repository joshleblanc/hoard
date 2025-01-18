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

        @overlap = opts[:overlap] || false
      end

      def reverse
        @opts.reverse || false
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
        ((frames - 1) * speed_ratio) + speed_ratio
      end

      def frame
        frame_over_speed.to_i % frames
      end

      def loops
        (frame_over_speed / frames).floor.abs
      end

      def tile_x
        files ? 0 : @opts.x + (tile_w * frame)
      end

      def tile_w
        @opts[:tile_w] || entity.tile_w
      end

      def tile_h
        @opts[:tile_h] || entity.tile_h
      end

      def path
        files ? files[frame] : @opts.path
      end

      def tile_y
        files ? 0 : @opts.y
      end

      def starting_frame
        if reverse
          frame_length
        else
          0
        end
      end

      def play!(should_loop = false, &callback)
        entity.send_to_scripts(:play_animation, id, should_loop, &callback)
      end

      def play_animation(id, should_loop = false, &callback)
        if id == @id && !playing?
          @frame = starting_frame
        end

        if @overlap && id == @id
          @playing = true
        end

        @playing = id == @id unless @overlap

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

        p "Running done: #{frame}, #{starting_frame}, #{frame == starting_frame}, #{loops}" if @id == :player_projectile
        loops > 0 && frame == (reverse ? frames - 1 : 0)
      end

      def post_update
        return unless playing?

        tmpX = entity.x
        tmpY = entity.y

        if entity.cd.has("shaking")
          tmpX += Math.cos(entity.ftime * 1.1) * entity.shake_pow_x * entity.cd.get_ratio("shaking")
          tmpY += Math.sin(0.3 + entity.ftime * 1.7) * entity.shake_pow_y * entity.cd.get_ratio("shaking")
        end

        sprite = {
          x: entity.rx + @offset_x,
          y: entity.ry + @offset_y,
          w: entity.rw,
          h: entity.rh,
          tile_w: tile_w,
          tile_h: tile_h,
          tile_x: tile_x,
          tile_y: tile_y,
          path: path,
          flip_horizontally: entity.flip_horizontally,
          flip_vertically: entity.flip_vertically,
          anchor_x: entity.anchor_x,
          anchor_y: entity.anchor_y,
        }

        outputs[:scene].sprites << sprite if entity.visible?

        # p @frame if @id == :player_projectile
        @frame = @frame + (reverse ? -1 : 1)

        if done?
          @playing = false
          @callback.call if @callback
        end
      end
    end
  end
end
