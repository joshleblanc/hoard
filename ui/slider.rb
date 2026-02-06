module Hoard
  module Ui
    class Slider < Component
      attr_accessor :value, :min, :max, :step, :label_text, :on_change,
                    :tooltip, :show_value

      def initialize(x:, y:, w: 200, h: nil, value: 0, min: 0, max: 100,
                     step: 1, label_text: "", on_change: nil, tooltip: nil,
                     show_value: true, **opts)
        @value = value.clamp(min, max)
        @min = min
        @max = max
        @step = step
        @label_text = label_text
        @on_change = on_change
        @tooltip = tooltip
        @show_value = show_value
        @dragging = false

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        h ||= [t.size(:slider_thumb) + 12, 30].max
        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        return unless @enabled

        mouse = args.inputs.mouse

        if mouse.click && @hovered
          @dragging = true
          update_value_from_mouse(args)
        end

        if @dragging && mouse.held
          update_value_from_mouse(args)
        end

        if @dragging && mouse.up
          @dragging = false
        end

        if @focused
          kb = args.inputs.keyboard
          adjust(-@step) if kb.key_down.left || kb.key_held.left
          adjust(@step)  if kb.key_down.right || kb.key_held.right
        end
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        track_h = t.size(:slider_h)
        thumb_size = t.size(:slider_thumb)
        track_pad = thumb_size / 2

        label_offset = 0
        unless @label_text.empty?
          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_primary]
          prims << label(@x, @y + @h / 2, @label_text, fg,
                         size_px: 18, font: t.font, anchor_x: 0, anchor_y: 0.5)
          lw = $gtk ? $gtk.calcstringbox(@label_text, 0)[0] : @label_text.length * 9
          label_offset = lw + 10
        end

        value_offset = 0
        if @show_value
          value_text = @step < 1 ? "%.1f" % @value : @value.to_i.to_s
          vw = $gtk ? $gtk.calcstringbox(value_text, 0)[0] : value_text.length * 9
          value_offset = vw + 10
        end

        track_x = @x + label_offset + track_pad
        track_w = @w - label_offset - value_offset - thumb_size
        track_y = @y + (@h - track_h) / 2

        track_bg = @state == :disabled ? t.colors[:bg_disabled] : t.colors[:bg_surface]
        prims << solid(track_x, track_y, track_w, track_h, track_bg)
        prims << border(track_x, track_y, track_w, track_h, t.colors[:border])

        pct = (@value - @min).to_f / (@max - @min)
        fill_w = (track_w * pct).to_i
        fill_color = @state == :disabled ? t.colors[:accent_disabled] : t.colors[:accent]
        prims << solid(track_x, track_y, fill_w, track_h, fill_color) if fill_w > 0

        thumb_x = track_x + fill_w - thumb_size / 2
        thumb_y = @y + (@h - thumb_size) / 2
        thumb_color = if @dragging then { r: 255, g: 255, b: 255 }
                      elsif @hovered then t.colors[:accent_hover]
                      elsif @state == :disabled then t.colors[:text_disabled]
                      else t.colors[:accent]
                      end
        prims << solid(thumb_x, thumb_y, thumb_size, thumb_size, thumb_color)
        prims << border(thumb_x, thumb_y, thumb_size, thumb_size, t.colors[:border])

        if @focused
          prims << border(thumb_x - 2, thumb_y - 2, thumb_size + 4, thumb_size + 4,
                          t.colors[:border_focus])
        end

        if @show_value
          value_text = @step < 1 ? "%.1f" % @value : @value.to_i.to_s
          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_secondary]
          prims << label(@x + @w - value_offset + 10, @y + @h / 2, value_text, fg,
                         size_px: 18, font: t.font, anchor_x: 0, anchor_y: 0.5)
        end

        @track_x = track_x
        @track_w = track_w

        prims
      end

      private

      def adjust(delta)
        old = @value
        @value = (@value + delta).clamp(@min, @max)
        @on_change.call(self) if @value != old && @on_change
      end

      def update_value_from_mouse(args)
        mouse_x = args.inputs.mouse.x
        track_x = @track_x || @x
        track_w = @track_w || @w

        pct = ((mouse_x - track_x).to_f / track_w).clamp(0.0, 1.0)
        raw = @min + pct * (@max - @min)
        stepped = (raw / @step).round * @step
        old = @value
        @value = stepped.clamp(@min, @max)
        @on_change.call(self) if @value != old && @on_change
      end
    end
  end
end
