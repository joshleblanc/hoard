module Hoard
  class Widget
    attr_gtk

    attr_accessor :entity, :visible

    attr :rows, :cols, :row, :col, :offset_x, :offset_y

    def initialize(rows: 12, cols: 24, row: 0, col: 0)
      @visible = false
      @rows = rows
      @cols = cols
      @row = row
      @col = col

      @offset_x = 0
      @offset_y = 0
    end

    def wrap_layout(parent, child)
      puts (parent.y - child.y)
      child.merge({
        x: child.x + (parent.x - child.x),
        y: child.y + (parent.y - child.y),
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
    end

    def rect(...)
      tmp = layout.rect(...)
      tmp.x += @offset_x
      tmp.y += @offset_y
      tmp
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

    def on_pre_step_x; end
    def on_pre_step_y; end
    def init; end
    def on_collision(entity); end
  end
end
