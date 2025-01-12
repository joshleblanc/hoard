# https://github.com/deepnight/gameBase/blob/master/src/game/Entity.hx

module Hoard
  class Entity < Process
    include Scriptable
    include Widgetable

    attr_sprite

    GRID = 16

    ##
    # cx, cy are grid coords
    # xr, yr are ratios
    # xx, yy are cx,cy + xr,xy
    # dx, dy are change in x, y
    attr :cx, :cy, :xr, :yr

    # world coords
    attr :wx, :wy

    attr :squash_x, :squash_y, :scale_x, :scale_y

    attr :dx_total, :dy_total, :destroyed, :dir, :visible, :dir, :collidable

    attr :cd, :ucd, :fx
    attr :all_velocities, :v_base, :v_bump

    attr :animation, :animations

    class << self
      attr_accessor :hidden, :collidable

      def resolve(id)
        resolution = nil

        ObjectSpace.each_object(Class) do |c|
          if c.name&.split("::")&.last == id
            resolution = c  # can't return from here for some reason
            break
          end
        end

        return resolution
      end

      def collidable
        self.collidable = true
      end

      def hidden
        self.hidden = true
      end
    end

    def initialize(parent: nil, cx: 0, cy: 0, tile_w: Const::GRID, tile_h: Const::GRID, w: Const::GRID, h: Const::GRID)
      super(parent)

      set_pos_case(cx, cy)
      @dir = 1
      @w = w
      @h = h
      @tile_w = tile_w
      @tile_h = tile_h

      @visible = !self.class.instance_variable_get(:@hidden)
      @collidable = !!self.class.instance_variable_get(:@collidable)

      @dx = 0
      @dy = 0

      @squash_x = 1
      @squash_y = 1
      @scale_x = 1
      @scale_y = 1

      @cd = Cooldown.new
      @ucd = Cooldown.new

      @all_velocities = Phys::VelocityArray.new
      @v_base = register_new_velocity(0.82)
      @v_bump = register_new_velocity(0.93)

      add_default_scripts!
      add_default_widgets!

      add_script Scripts::DebugRenderScript.new
    end

    def register_new_velocity(frict)
      v = Phys::Velocity.create_frict(frict)
      @all_velocities.push(v)
      v
    end

    def squash_x=(scale)
      @squash_x = scale
      @squash_y = 2 - scale
    end

    def squash_y=(scale)
      @squash_x = 2 - scale
      @squash_y = scale
    end

    def shake_s(x_pow, y_pow, t)
      cd.set_s("shaking", t, true)
      @shake_pow_x = x_pow
      @shake_pow_y = y_pow
    end

    def set_pos_case(x, y)
      self.cx = x
      self.cy = y
      self.xr = 0.5
      self.yr = 1
    end

    def update_world_pos
      level = Game.s.current_level
      self.wx = self.x + level.world_x
      self.wy = self.y + level.world_y
    end

    def x
      xx * GRID
    end

    def wcx
      (wx / Const::GRID).to_i
    end

    def wcy
      (wy / Const::GRID).to_i - 1
    end

    def y
      yy * GRID
    end

    def xx
      cx + xr
    end

    def yy
      cy + yr
    end

    def rx
      x
    end

    def ry
      y.from_top + h
    end

    def rw
      (w * scale_x) / squash_x
    end

    def rh
      (h * scale_y) / squash_y
    end

    def intersect?(cx, cy)
      cx_span = w / GRID
      cy_span = h / GRID

      cx_half = (cx_span / 2).floor
      cy_half = (cy_span / 2).floor

      left = self.cx - cx_half
      bottom = self.cy + cy_half

      # p "#{left..(left + cx_half)}, #{bottom..(bottom + cy_half)}"
      (left..(left + (cx_half * 2))).cover?(cx) && (bottom..(bottom + (cy_half * 2))).cover?(cy)
    end

    def check_collision(entity, cx, cy)
      return if entity == self
      if entity.collidable && entity.intersect?(cx - 1, cy)
        if self == Game.s.player
          # If we're checking one unit below (for ground detection)
          if cy > self.cy
            return true # Always allow ground collision checks
          else
            moving_down = dy_total > 0
            above_platform = cy < entity.cy
            return moving_down || above_platform
          end
        end
        return true
      end

      entity.children.each do |child|
        return true if check_collision(child, cx, cy)
      end

      return false
    end

    def on_ground?
      !destroyed? && v_base.dy == 0 && yr == 1 && has_collision(cx, cy + 1)
    end

    def has_collision(x, y)
      return true if Game.s.current_level&.has_collision(x, y)

      if @collidable
        Game.s.children.each do |entity|
          return true if check_collision(entity, x, y)
        end
      end

      false
    end

    def has_exit?(x, y)
      Game.s.current_level&.outside?(x, y)
    end

    def destroyed?
      destroyed
    end

    def on_pre_step_x
      send_to_scripts(:on_pre_step_x)
      send_to_widgets(:on_pre_step_x)
    end

    def on_pre_step_y
      send_to_scripts(:on_pre_step_y)
      send_to_widgets(:on_pre_step_y)
    end

    def apply_damage(amt, from = nil)
      send_to_scripts(:on_damage, amt, from)
      send_to_widgets(:on_damage, amt, from)
    end

    # beginning of frame loop - called before any other entity update loop
    def pre_update
      super

      send_to_scripts(:args=, args)
      send_to_widgets(:args=, args)
      send_to_scripts(:pre_update)
      send_to_widgets(:pre_update)

      return if destroyed?

      # call on_collision on the player
      return if Game.s.player == self
      return unless Geometry.intersect_rect?(Game.s.player, self)

      Game.s.player.send_to_scripts(:on_collision, self)
      send_to_scripts(:on_collision, Game.s.player)
      send_to_widgets(:on_collision, Game.s.player)

      if Game.s.inputs.keyboard.key_down.e
        send_to_scripts(:on_interact, Game.s.player)
        send_to_widgets(:on_interact, Game.s.player)
      end
    end

    def center_x
      rect_center_point.x
    end

    def center_y
      rect_center_point.y - (h * 2)
    end

    def visible?
      visible
    end

    def show!
      self.visible = true
    end

    def hide!
      self.visible = false
    end

    def tmod
      1
    end

    def gx
      Game.s.camera.level_to_global_x(x)
    end

    def gy
      Game.s.camera.level_to_global_y((y - h).from_top)
    end

    # called after pre_update and update
    # usually used for rendering
    def post_update
      super

      self.flip_horizontally = dir < 0

      @squash_x += (1 - @squash_x) * [1, 0.2 * tmod].min
      @squash_y += (1 - @squash_y) * [1, 0.2 * tmod].min

      send_to_scripts(:post_update) if server?
      send_to_scripts(:client_post_update) if client?
      send_to_scripts(:local_post_update) if local?

      send_to_widgets(:post_update)

      args.outputs.sprites << {
        x: x,
        y: y,
        w: w,
        h: h,
        r: 0, g: 255, b: 0,
      }
    end

    def dx_total
      @all_velocities.sum_x
    end

    def dy_total
      @all_velocities.sum_y
    end

    def ftime
      $args.state.tick_count
    end

    def init
      send_to_scripts(:args=, args)
      send_to_scripts(:init) if server?
      send_to_scripts(:local_init) if local?
      send_to_scripts(:client_init) if client?
      send_to_widgets(:args=, args)
      send_to_widgets(:init)
    end

    # I'm not going to pretend to know what this does
    def update
      steps = ((dx_total.abs + dy_total.abs) / 0.33).ceil
      if steps > 0
        n = 0
        while (n < steps)
          self.xr += dx_total / steps
          on_pre_step_x if dx_total != 0

          while xr > 1
            self.xr -= 1
            self.cx += 1
          end

          while xr < 0
            self.xr += 1
            self.cx -= 1
          end

          self.yr += dy_total / steps

          on_pre_step_y if dy_total != 0

          while yr > 1
            self.yr -= 1
            self.cy += 1
          end

          while yr < 0
            self.yr += 1
            self.cy -= 1
          end

          n += 1
        end
      end

      all_velocities.each(&:update)
      cd.update(tmod)
      ucd.update(tmod)
      update_world_pos

      send_to_scripts(:update) if server?
      send_to_scripts(:client_update) if client?
      send_to_scripts(:local_update) if local?

      send_to_widgets(:update)
    end

    def shutdown
      send_to_scripts(:on_shutdown)
      send_to_widgets(:on_shutdown)
    end
  end
end
