module Hoard
  class Fx < Process
    attr :emitters, :particles

    def initialize
      super

      @emitters = []
      @particles = []
      @anims = []
    end

    def process_anims
      @anims.each do |anim|
        duration = $args.state.tick_count - anim.start_tick
        anim.current_frame = (duration / (anim.speed || 4)).to_i % anim.frames
        anim.tile_x = (anim.tile_w * anim.current_frame)
      end

      @anims.delete_if { _1.current_frame >= (_1.frames - 1) }
    end

    # args.state.blendmodes ||= [
    #     { name: :none,  value: 0 },
    #     { name: :blend, value: 1 },
    #     { name: :add,   value: 2 },
    #     { name: :mod,   value: 3 },
    #     { name: :mul,   value: 4 }
    #   ]

    ##
    # for(i in 0...80) {
    # 	var p = allocMain_add( D.tiles.fxDot, x+rnd(0,3,true), y+rnd(0,3,true) );
    # 	p.alpha = rnd(0.4,1);
    # 	p.colorAnimS(color, 0x762087, rnd(0.6, 3)); // fade particle color from given color to some purple
    # 	p.moveAwayFrom(x,y, rnd(1,3)); // move away from source
    # 	p.frict = rnd(0.8, 0.9); // friction applied to velocities
    # 	p.gy = rnd(0, 0.02); // gravity Y (added on each frame)
    # 	p.lifeS = rnd(2,3); // life time in seconds
    # }
    def dots_explosion(x, y, color = 0xffffff)
      80.times do |i|
        px = x + rnd(0, 3, true)
        py = y + rnd(0, 3)
        spd = rnd(1, 3)

        a = Math.atan2(y - py, x - px)
        dx = -Math.cos(a) * spd
        dy = -Math.sin(a) * spd
        @particles.push({
          x: px, y: py, w: 2, h: 2,
          path: "sprites/circle/white.png",
          xvel: dx,
          yvel: dy,
          frict: rnd(0.8, 0.9),
          grav: true, grav_x: 0.0, grav_y: rnd(0, -0.02),
          anchor_x: 0.5, anchor_y: 0.5,
          time: $args.tick_count + 15,
          blendmode_enum: 0,
          spawn_time: $args.tick_count,
          fade: true, fade_start: rnd(0.4, 1) * 255, fade_end: 0, fade_ease: :quint,
          color_start: color,
          color_end: 0x762987,
        })
      end
    end

    def anim(data)
      data.anchor_x = 0.5
      data.anchor_y = 0.5
      data.w = data.w || Const::GRID
      data.h = data.h || Const::GRID
      data.start_tick = $args.state.tick_count
      data.flip_vertically = true
      @anims.push(data)
    end

    def draw_override(ffi_draw)
      @particles.each do |p|
        ffi_draw.draw_sprite_hash(p)
      end

      @anims.each do |a|
        ffi_draw.draw_sprite_hash(a)
      end
    end

    def ease_part(p, from, to)
      $args.easing.ease(
        p.spawn_time,
        $args.tick_count,
        p.time - p.spawn_time,
        p.fade_ease
      ).remap(
        0, 1,
        from, to
      )
    end

    def update
      process_emitters(@emitters, @particles, $args)
      process_particles(@particles, $args)
      process_anims
    end

    def post_update
      args.outputs[:scene].sprites.push(self)
    end
  end
end
