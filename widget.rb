module Hoard
  class Widget
    attr_gtk

    attr_accessor :entity, :visible

    attr :rows, :cols, :row, :col, :offset_x, :offset_y
    attr_reader :uuid

    PADDING = 18

    def initialize
      @visible = true

      @offset_x = 0
      @offset_y = 0

      @windows = {}

      @uuid = $gtk.create_uuid
    end

    def window(**attrs, &blk)
      window = @windows[attrs[:key]]

      if window
        # Always update window properties and evaluate block
        window.update_options(**attrs, widget: self, key: uuid, &blk)
      else
        @windows[attrs[:key]] = Ui::Window.new(**attrs, widget: self, key: uuid, &blk)
      end

      @windows[attrs[:key]].render
      @windows[attrs[:key]].each(&:render)
    end

    def render
    end

    def pre_update
      element_lifecycle(:pre_update)
      # if args.inputs.mouse.button_left
      #   if args.inputs.mouse.inside_rect?(container) && !@dragging
      #     @dragging = true
      #     @drag_x = args.inputs.mouse.x - @offset_x
      #     @drag_y = args.inputs.mouse.y - @offset_y
      #   end
      # else
      #   @dragging = false
      # end
    end

    def element_lifecycle(method)
      @windows.each do |k, v|
        v.send(method)
        v.each { _1.send(method) }
      end
    end

    def update
      element_lifecycle(:update)

      return unless @dragging

      @offset_x = args.inputs.mouse.x - @drag_x
      @offset_y = args.inputs.mouse.y - @drag_y
    end

    def post_update
      element_lifecycle(:post_update)
      render if visible?
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
      ::Game.s.camera.level_to_global_x(from)
    end

    def screen_y(from)
      ::Game.s.camera.level_to_global_y(from)
      #Game.s.camera.level_to_global_y(from)
    end

    def screen_w(from)
      from / ::Game::SCALE
    end

    def grid_x(from)
      screen_x(from) / (1280 / 24)
    end

    def grid_y(from)
      (screen_y(from) / (720 / 12))
    end

    def on_pre_step_x; end
    def on_pre_step_y; end
    def init; end
    def on_collision(entity); end
  end
end
