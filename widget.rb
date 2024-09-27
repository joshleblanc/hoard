module Hoard
  class Widget
    attr_gtk

    attr_accessor :entity, :visible

    attr :rows, :cols, :row, :col, :offset_x, :offset_y

    PADDING = 18

    def initialize(rows: 12, cols: 24, row: 0, col: 0)
      @visible = false
      @rows = rows
      @cols = cols
      @row = row
      @col = col

      @offset_x = 0
      @offset_y = 0
    end

    def bordered_container!
      bordered_rect!(container)
    end

    def button!(h, label, cb = nil)
      t = text(h, label)
      sprite, border = bordered_rect(**h)

      if inputs.mouse.inside_rect?(h)
        # puts h
        sprite.r = 255
        sprite.g = 255
        sprite.b = 255

        t.r = 0
        t.g = 0
        t.b = 0

        if inputs.mouse.click
          cb&.call
        end
      end

      outputs[:ui].sprites << sprite
      outputs[:ui].primitives << border
      outputs[:ui].labels << t
    end

    def button(h, label)
      t = text(h, label)
      if inputs.mouse.inside_rect?(h)
        t.r = t.r % 255
        t.g = t.g % 255
        t.b = t.b % 255
      end
      t
    end

    def bordered_rect(**h)
      bg = {
        r: 0, b: 0, g: 0, a: 125,
        **h,
      }
      border = {
        primitive_marker: :border,
        r: 0, b: 0, g: 0, a: 255,
        **h.except(:path),
      }
      [bg, border]
    end

    def bordered_rect!(**h)
      sprite, border = bordered_rect(**h)
      outputs[:ui].sprites << sprite
      outputs[:ui].primitives << border
    end

    def window(**attrs, &blk)
      root = Ui::Window.new(**attrs, widget: self, &blk)
      
      outputs[:ui].borders << {
          x: root.x, y: root.y, w: root.w, h: root.h,
          r: 255, g: 0, b: 0
      }

      outputs[:ui].sprites << {
          x: root.x, y: root.y, w: root.w, h: root.h,
          r: 0, g: 0, b: 0, a: 125
      }

      root.each(&:render)
    end

    def render
    end

    def text!(...)
      outputs[:ui].labels << text(...)
    end

    def text(h, t, size_enum: 0)
      copy = { **h }
      label_w, label_h = gtk.calcstringbox(t)
      copy.x = copy.x + (h.w / 2) - (label_w / 2)
      copy.y = copy.y - (h.h / 2) + (label_h / 2) + h.h
      copy.merge(r: 255, g: 255, b: 255, a: 255, text: t, size_enum: size_enum)
    end

    def rect(...)
      tmp = layout.rect(...)
      tmp.x += @offset_x
      tmp.y += @offset_y
      tmp
    end

    def wrap_layout(parent, child)
      child_y_pos = (child.y + child.h)
      parent_y_pos = (parent.y.from_top - parent.h)

      child.merge({
        x: child.x + parent.x - @offset_x - PADDING,
        y: child_y_pos - parent_y_pos - @offset_y + 2, # gunna be honest, I don't know why we're off by 2px
      })
    end

    def pre_update
      if args.inputs.mouse.button_left
        if args.inputs.mouse.inside_rect?(container) && !@dragging
          @dragging = true
          @drag_x = args.inputs.mouse.x - @offset_x
          @drag_y = args.inputs.mouse.y - @offset_y
        end
      else
        @dragging = false
      end
    end

    def update
      return unless @dragging

      @offset_x = args.inputs.mouse.x - @drag_x
      @offset_y = args.inputs.mouse.y - @drag_y
    end

    def post_update
      render if visible?
    end

    def container
      rect(row: row, col: col, w: cols, h: rows)
    end

    def to_h
      {}.tap do |klass|
        instance_variables.reject { _1 == :@entity || _1 == :@args }.each do |k|
          klass[k.to_s[1..-1].to_sym] = instance_variable_get(k)
        end
      end
    end

    def serialize
      to_h
    end

    def to_s
      serialize.to_s
    end

    def visible?
      visible
    end

    def show!
      @visible = true
    end

    def hide!
      @visible = false
    end

    def toggle!
      @visible = !@visible
    end

    # def label()
    #   outputs[:ui] << {}
    # end

    def screen_x(from)
      Game.s.camera.level_to_global_x(from)
    end

    def screen_y(from)
      Game.s.camera.level_to_global_y(from)
      #Game.s.camera.level_to_global_y(from)
    end

    def screen_w(from)
      from / Hoard::Const.scale
    end

    def grid_x(from)
      screen_x(from) / (1280 / 24)
    end

    def grid_y(from)
      (screen_y(from) / (720 / 12)).from_top
    end

    def on_pre_step_x; end
    def on_pre_step_y; end
    def init; end
    def on_collision(entity); end
  end
end
