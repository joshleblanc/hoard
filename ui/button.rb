module Hoard
  module Ui
    class Button < Component
      attr_accessor :text, :on_click, :tooltip, :style, :size, :icon_path

      def initialize(x:, y:, w: nil, h: nil, text: "Button", style: :default,
                     size: :md, on_click: nil, tooltip: nil, icon_path: nil, **opts)
        @text = text
        @style = style
        @size = size
        @on_click = on_click
        @tooltip = tooltip
        @icon_path = icon_path
        @pressed = false
        @click_at = -100

        h ||= size_config[:h]
        w ||= compute_auto_width

        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        return unless @enabled

        mouse = args.inputs.mouse

        if @hovered && mouse.click
          @pressed = true
          @click_at = Kernel.tick_count
        end

        if @pressed && mouse.up
          @pressed = false
          @on_click.call(self) if @hovered && @on_click
        end

        if @focused && args.inputs.keyboard.key_down.enter
          @click_at = Kernel.tick_count
          @on_click.call(self) if @on_click
        end
      end

      def prefab
        return [] unless @visible
        prims = []
        t = theme

        bg, fg, brd = colors_for_state(t)

        anim_elapsed = Kernel.tick_count - @click_at
        if anim_elapsed < t.size(:anim_fast)
          bg = { r: [bg[:r] + 30, 255].min,
                 g: [bg[:g] + 30, 255].min,
                 b: [bg[:b] + 30, 255].min }
        end

        prims << solid(@x, @y, @w, @h, bg)
        prims << border(@x, @y, @w, @h, brd) unless @style == :ghost && @state == :normal

        if @focused
          prims << border(@x - 2, @y - 2, @w + 4, @h + 4, t.colors[:border_focus])
        end

        text_x = @x + @w / 2
        if @icon_path
          icon_s = size_config[:icon]
          icon_x = @x + size_config[:pad]
          icon_y = @y + (@h - icon_s) / 2
          prims << { x: icon_x, y: icon_y, w: icon_s, h: icon_s,
                     path: @icon_path, r: fg[:r], g: fg[:g], b: fg[:b], a: fg[:a] || 255 }
          text_x = icon_x + icon_s + 6 + ((@w - icon_s - 6 - size_config[:pad]) / 2)
        end

        prims << label(text_x, @y + @h / 2, @text, fg,
                       size_px: size_config[:font], font: t.font,
                       anchor_x: 0.5, anchor_y: 0.5)

        prims
      end

      private

      def size_config
        case @size
        when :sm then { h: 30, font: 16, pad: 10, icon: 14 }
        when :lg then { h: 50, font: 24, pad: 20, icon: 22 }
        else          { h: 40, font: 20, pad: 14, icon: 18 }
        end
      end

      def compute_auto_width
        sc = size_config
        tw, _th = $gtk ? $gtk.calcstringbox(@text, 0) : [(@text.length * 10), 22]
        base = tw + sc[:pad] * 2
        base += sc[:icon] + 6 if @icon_path
        [base, 80].max
      end

      def colors_for_state(t)
        case @style
        when :primary
          bg_key = case @state
                   when :active then :accent_active
                   when :hover  then :accent_hover
                   when :disabled then :accent_disabled
                   else :accent
                   end
          fg_key = @state == :disabled ? :text_disabled : :text_on_accent
          [t.colors[bg_key], t.colors[fg_key], t.colors[bg_key]]

        when :success
          base = t.colors[:success]
          fg = { r: 15, g: 30, b: 20 }
          case @state
          when :hover  then [lighten(base, 20), fg, lighten(base, 20)]
          when :active then [darken(base, 20), fg, darken(base, 20)]
          when :disabled then [t.colors[:bg_disabled], t.colors[:text_disabled], t.colors[:border]]
          else [base, fg, base]
          end

        when :warning
          base = t.colors[:warning]
          fg = { r: 30, g: 25, b: 10 }
          case @state
          when :hover  then [lighten(base, 20), fg, lighten(base, 20)]
          when :active then [darken(base, 20), fg, darken(base, 20)]
          when :disabled then [t.colors[:bg_disabled], t.colors[:text_disabled], t.colors[:border]]
          else [base, fg, base]
          end

        when :danger
          base = t.colors[:error]
          fg = { r: 255, g: 230, b: 230 }
          case @state
          when :hover  then [lighten(base, 20), fg, lighten(base, 20)]
          when :active then [darken(base, 20), fg, darken(base, 20)]
          when :disabled then [t.colors[:bg_disabled], t.colors[:text_disabled], t.colors[:border]]
          else [base, fg, base]
          end

        when :ghost
          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_primary]
          case @state
          when :hover  then [t.colors[:bg_hover], fg, t.colors[:border_hover]]
          when :active then [t.colors[:bg_active], fg, t.colors[:border_hover]]
          else [t.colors[:transparent], fg, t.colors[:transparent]]
          end

        else
          bg_key = case @state
                   when :active then :bg_active
                   when :hover  then :bg_hover
                   when :disabled then :bg_disabled
                   else :bg_surface
                   end
          fg_key = @state == :disabled ? :text_disabled : :text_primary
          brd_key = case @state
                    when :hover, :active then :border_hover
                    else :border
                    end
          [t.colors[bg_key], t.colors[fg_key], t.colors[brd_key]]
        end
      end

      def lighten(color, amount)
        { r: [color[:r] + amount, 255].min,
          g: [color[:g] + amount, 255].min,
          b: [color[:b] + amount, 255].min }
      end

      def darken(color, amount)
        { r: [color[:r] - amount, 0].max,
          g: [color[:g] - amount, 0].max,
          b: [color[:b] - amount, 0].max }
      end
    end
  end
end
