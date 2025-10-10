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
        @horizontal_frames = if opts.has_key? :horizontal_frames
          opts[:horizontal_frames]
        else
          true
        end

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
        if files 
          0 
        elsif @horizontal_frames
          @opts.x + (tile_w * frame)
        else
          @opts.x
        end
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
        if files 
          0 
        elsif @horizontal_frames
          @opts.y
        else
          @opts.y + (tile_h * frame)
        end
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

        loops > 0 && frame == (reverse ? frames - 1 : 0)
      end

      def w
        @opts[:w] || entity.rw
      end

      def h
        @opts[:h] || entity.rh
      end

      def post_update
        return unless playing?

        tmp_x = entity.rx
        tmp_y = entity.ry

        if entity.cd.has("shaking")
          tmp_x += Math.cos(entity.ftime * 1.1) * entity.shake_pow_x * entity.cd.get_ratio("shaking")
          tmp_y += Math.sin(0.3 + entity.ftime * 1.7) * entity.shake_pow_y * entity.cd.get_ratio("shaking")
        end

        sprite = {
          x: tmp_x + @offset_x,
          y: tmp_y + @offset_y,
          w: w,
          h: h,
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
