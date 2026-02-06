module Hoard
  module Ui
    class Toggle < Component
      attr_accessor :on, :label_text, :on_change, :tooltip

      def initialize(x:, y:, on: false, label_text: "", on_change: nil,
                     tooltip: nil, **opts)
        @on = on
        @label_text = label_text
        @on_change = on_change
        @tooltip = tooltip
        @anim_progress = on ? 1.0 : 0.0

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        tw = t.size(:toggle_w)
        th = t.size(:toggle_h)
        label_w = label_text.empty? ? 0 : label_text.length * 10 + 8
        w = opts.delete(:w) || tw + label_w
        h = opts.delete(:h) || [th, 28].max

        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)

        target = @on ? 1.0 : 0.0
        @anim_progress = @anim_progress.lerp(target, 0.25)

        return unless @enabled

        mouse = args.inputs.mouse
        if (mouse.click && @hovered) ||
           (@focused && args.inputs.keyboard.key_down.space)
          @on = !@on
          @on_change.call(self) if @on_change
        end
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        tw = t.size(:toggle_w)
        th = t.size(:toggle_h)
        track_x = @x
        track_y = @y + (@h - th) / 2

        track_color = if @state == :disabled
                        t.colors[:bg_disabled]
                      elsif @on
                        t.colors[:accent]
                      else
                        t.colors[:bg_surface]
                      end
        prims << solid(track_x, track_y, tw, th, track_color)

        brd = if @focused then t.colors[:border_focus]
              elsif @hovered then t.colors[:border_hover]
              elsif @on then t.colors[:accent]
              else t.colors[:border]
              end
        prims << border(track_x, track_y, tw, th, brd)

        if @focused
          prims << border(track_x - 2, track_y - 2, tw + 4, th + 4,
                          t.colors[:border_focus])
        end

        thumb_pad = 3
        thumb_size = th - thumb_pad * 2
        thumb_range = tw - thumb_size - thumb_pad * 2
        thumb_x = track_x + thumb_pad + (thumb_range * @anim_progress)
        thumb_y = track_y + thumb_pad

        thumb_color = @state == :disabled ? t.colors[:text_disabled] : { r: 255, g: 255, b: 255 }
        prims << solid(thumb_x, thumb_y, thumb_size, thumb_size, thumb_color)

        unless @label_text.empty?
          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_primary]
          prims << label(track_x + tw + 8, @y + @h / 2, @label_text, fg,
                         size_px: 20, font: t.font,
                         anchor_x: 0, anchor_y: 0.5)
        end

        prims
      end
    end
  end
end
