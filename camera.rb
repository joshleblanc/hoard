module Hoard
  class Camera < Process
    MIN_ZOOM = 1
    MAX_ZOOM = 1

    attr :raw_focus, :clamped_focus, :dx, :dy, :dz
    attr :target, :target_off_x, :target_off_y
    attr :dead_zone_pct_x, :dead_zone_pct_y, :base_frict

    attr :bump_off_x, :bump_off_y, :bump_frict, :bump_zoom_factor
    attr :base_zoom, :zoom_speed, :zoom_frict, :target_zoom
    attr :tracking_speed, :clamp_to_level_bounds, :brake_dist_near_bounds
    attr :shake_power

    # stuff from process
    attr :cd, :tmod

    def initialize
      super

      @raw_focus = LPoint.from_case(0, 0)
      @clamped_focus = LPoint.from_case(0, 0)
      @dx = 0
      @dy = 0
      @dz = 0

      @target_off_x = 0.0
      @target_off_y = 0.0
      @dead_zone_pct_x = 0.04
      @dead_zone_pct_y = 0.10
      @base_frict = 0.89

      @bump_off_x = 0.0
      @bump_off_y = 0.0
      @bump_frict = 0.85
      @bump_zoom_factor = 0.0

      @base_zoom = 1.0
      @zoom_speed = 0.0014
      @zoom_frict = 0.9

      @target_zoom = 1.0
      @tracking_speed = 1.0
      @clamp_to_level_bounds = false
      @brake_dist_near_bounds = 0.1

      @shake_power = 1

      @cd = Cooldown.new
      @tmod = 1
    end

    def zoom
      base_zoom + bump_zoom_factor
    end

    def target_zoom=(z)
      @target_zoom = z.clamp(MIN_ZOOM, MAX_ZOOM)
    end

    def zoom_to(z)
      self.target_zoom = z
    end

    def force_zoom(z)
      self.target_zoom = z
      self.base_zoom = target_zoom
      self.dz = 0
    end

    def bump_zoom(z)
      self.bump_zoom_factor = z
    end

    def px_wid
      (Scaler.viewport_width / Hoard.config.game_class::SCALE / zoom).ceil
    end

    def px_hei
      (Scaler.viewport_height / Hoard.config.game_class::SCALE / zoom).ceil
    end

    def on_screen?(level_x, level_y, padding = 0.0)
      level_x >= (px_left - padding) && level_x <= (px_right + padding) && level_y >= (px_top - padding) && level_y <= (px_bottom + padding)
    end

    def on_screen_rect?(x, y, wid, hei, padding = 0.0)
      Geometry.intersect_rect?(
        [px_left - padding, px_top - padding, px_wid + (padding * 2), px_hei + (padding * 2)],
        [x, y, wid, hei]
      )
    end

    def on_screen_case?(cx, cy, padding = 32)
      cx * Hoard.config.game_class::GRID >= px_left - padding && (cx + 1) * Hoard.config.game_class::GRID <= px_right + padding &&
      cy * Hoard.config.game_class::GRID >= px_top - padding && (cy + 1) * Hoard.config.game_class::GRID <= px_bottom + padding
    end

    def track_entity(entity, immediate, speed = 1.0)
      self.target = entity
      self.tracking_speed = speed
      if immediate || self.raw_focus.level_x.zero? && self.raw_focus.level_y.zero?
        self.center_on_target
      else
        p "NOT calling center_on_target (immediate=#{immediate}, focus=#{raw_focus.level_x},#{raw_focus.level_y})"
      end
    end

    def tracking_speed=(s)
      @tracking_speed = s.clamp(0.01, 10)
    end

    def stop_tracking
      self.target = nil
    end

    def center_on_target
      return unless target

      self.raw_focus.level_x = target.center_x + target_off_x
      self.raw_focus.level_y = target.center_y + target_off_y
    end

    def level_to_global_x(v)
      scroller = Hoard.config.game_class.s.scroller
      scale = Hoard.config.game_class::SCALE * zoom
      # scroller.x is already scaled, so divide it back, then add level position
      (v + scroller.x / scale) * scale
    end

    def level_to_global_y(v)
      level = Hoard.config.game_class.s.current_level
      scroller = Hoard.config.game_class.s.scroller
      scale = Hoard.config.game_class::SCALE * zoom
      # Convert level coords (bottom-up) to flipped coords, then apply scroller
      flipped_y = level.px_hei - v
      (flipped_y + scroller.y / scale) * scale
    end

    def shake_s(t, pow = 1.0)
      cd.set_s("shaking", t, true)
      self.shake_power = pow
    end

    def bump_ang(a, dist)
      self.bump_off_x = Math.cos(a) * dist
      self.bump_off_y = Math.sin(a) * dist
    end

    def bump(x, y)
      self.bump_off_x += x
      self.bump_off_y += y
    end

    def ftime
      $args.state.tick_count
    end

    def apply
      level = Hoard.config.game_class.s.current_level
      scroller = Hoard.config.game_class.s.scroller

      # Update scroller dimensions to match level
      if level
        scroller.w = level.px_wid
        scroller.h = level.px_hei
      end

      scroller.x = -clamped_focus.level_x + px_wid * 0.5
      # For flipped coordinate system: convert level Y to flipped Y based on actual level height
      scroller.y = -(level.px_hei - clamped_focus.level_y) + px_hei * 0.5

      self.bump_off_x = bump_off_x * (bump_frict ** tmod)
      self.bump_off_y = bump_off_y * (bump_frict ** tmod)

      scroller.x -= bump_off_x
      scroller.y += bump_off_y

      if cd.has("shaking")
        scroller.x += Math.cos(ftime * 1.1) * 2.5 * shake_power * cd.get_ratio("shaking")
        scroller.y += Math.sin(0.3 + ftime * 1.7) * 2.5 * shake_power * cd.get_ratio("shaking")
      end

      #scaling
      scroller.x *= Hoard.config.game_class::SCALE * zoom
      scroller.y *= Hoard.config.game_class::SCALE * zoom

      scroller.x = scroller.x.round
      scroller.y = scroller.y.round

      scroller.scale = Hoard.config.game_class::SCALE * zoom
    end

    def update
      level = Hoard.config.game_class.s.current_level

      tz = target_zoom
      if tz != base_zoom
        if tz > base_zoom
          self.dz += zoom_speed
        else
          self.dz -= zoom_speed
        end
      else
        self.dz = 0
      end

      prev_zoom = base_zoom
      self.base_zoom += dz * tmod

      self.bump_zoom_factor *= 0.9 ** tmod
      self.dz *= zoom_frict ** tmod
      if (tz - base_zoom).abs <= 0.005 * tmod
        self.dz *= 0.8 ** tmod
      end

      if prev_zoom < tz && base_zoom >= tz || prev_zoom > tz && base_zoom <= tz
        self.base_zoom = tz
        self.dz = 0
      end

      if target
        spd_x = 0.015 * tracking_speed * zoom
        spd_y = 0.023 * tracking_speed * zoom
        tx = target.center_x + target_off_x
        ty = target.center_y + target_off_y

        a = raw_focus.ang_to(tx, ty)
        dist_x = (tx - raw_focus.level_x).abs
        if dist_x >= dead_zone_pct_x * px_wid
          self.dx += Math.cos(a) * (0.8 * dist_x - dead_zone_pct_x * px_wid) * spd_x * tmod
        end

        dist_y = (ty - raw_focus.level_y).abs
        if dist_y >= dead_zone_pct_y * px_hei
          self.dy += Math.sin(a) * (0.8 * dist_y - dead_zone_pct_y * px_hei) * spd_y * tmod
        end
      end

      frict_x = base_frict - tracking_speed * zoom * 0.027 * base_frict
      frict_y = frict_x

      if clamp_to_level_bounds
        brake_dist = brake_dist_near_bounds * px_wid
        if dx <= 0
          brake_ratio = 1 - ((raw_focus.level_x - px_wid * 0.5) / brake_dist).clamp(0, 1)
          frict_x *= 1 - 0.9 * brake_ratio
        elsif dx > 0
          brake_ratio = 1 - (((level.px_wid - px_wid * 0.5) - raw_focus.level_x) / brake_dist).clamp(0, 1)
          frict_x *= 1 - 0.9 * brake_ratio
        end

        brake_dist = brake_dist_near_bounds * px_hei
        if dy < 0
          brake_ratio = 1 - ((raw_focus.level_y - px_hei * 0.5) / brake_dist).clamp(0, 1)
          frict_y *= 1 - 0.9 * brake_ratio
        elsif dy >= 0
          brake_ratio = 1 - (((level.px_hei - px_hei * 0.5) - raw_focus.level_y) / brake_dist).clamp(0, 1)
          frict_y *= 1 - 0.9 * brake_ratio
        end
      else
        clamped_focus.level_x = raw_focus.level_x
        clamped_focus.level_y = raw_focus.level_y
      end

      raw_focus.level_x += dx * tmod
      self.dx *= frict_x ** tmod

      raw_focus.level_y += dy * tmod
      self.dy *= frict_y ** tmod

      if clamp_to_level_bounds
        if level.px_wid < px_wid
          clamped_focus.level_x = level.px_wid * 0.5
        else
          clamped_focus.level_x = raw_focus.level_x.clamp(px_wid * 0.5, level.px_wid - px_wid * 0.5)
        end

        if level.px_hei < px_hei
          clamped_focus.level_y = level.px_hei * 0.5
        else
          clamped_focus.level_y = raw_focus.level_y.clamp(px_hei * 0.5, level.px_hei - px_hei * 0.5)
        end
      else
        clamped_focus.level_x = raw_focus.level_x
        clamped_focus.level_y = raw_focus.level_y
      end

      apply
    end

    def c_wid
      (px_wid / Hoard.config.game_class::GRID).ceil
    end

    def c_hei
      (px_hei / Hoard.config.game_class::GRID).ceil
    end

    def px_left
      (clamped_focus.level_x - (px_wid * 0.5)).to_i
    end

    def px_right
      (px_left + px_wid - 1).to_i
    end

    def px_top
      (clamped_focus.level_y - (px_hei * 0.5)).to_i
    end

    def px_bottom
      (px_top + px_hei - 1).to_i
    end

    def center_x
      ((px_left + px_right) * 0.5).to_i
    end

    def center_y
      ((px_top + px_bottom) * 0.5).to_i
    end

    def c_left
      (px_left / Hoard.config.game_class::GRID).to_i
    end

    def c_right
      (px_right / Hoard.config.game_class::GRID).to_i
    end

    def c_top
      (px_top / Hoard.config.game_class::GRID).to_i
    end

    def c_bottom
      (px_bottom / Hoard.config.game_class::GRID).to_i
    end
  end
end
