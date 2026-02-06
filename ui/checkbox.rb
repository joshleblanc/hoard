module Hoard
  module Ui
    class Checkbox < Component
      attr_accessor :checked, :label_text, :on_change, :tooltip

      def initialize(x:, y:, checked: false, label_text: "", on_change: nil,
                     tooltip: nil, **opts)
        @checked = checked
        @label_text = label_text
        @on_change = on_change
        @tooltip = tooltip

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        box_size = t.size(:checkbox_size)
        label_w = label_text.length * 10 + 8
        w = opts.delete(:w) || box_size + label_w
        h = opts.delete(:h) || [box_size, 28].max

        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        return unless @enabled

        mouse = args.inputs.mouse
        if (mouse.click && @hovered) ||
           (@focused && args.inputs.keyboard.key_down.space)
          toggle!
        end
      end

      def toggle!
        @checked = !@checked
        @on_change.call(self) if @on_change
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []
        box_size = t.size(:checkbox_size)
        box_x = @x
        box_y = @y + (@h - box_size) / 2

        if @checked
          bg = @state == :disabled ? t.colors[:accent_disabled] : t.colors[:accent]
          prims << solid(box_x, box_y, box_size, box_size, bg)
        else
          bg = case @state
               when :hover  then t.colors[:bg_hover]
               when :active then t.colors[:bg_active]
               when :disabled then t.colors[:bg_disabled]
               else t.colors[:bg_primary]
               end
          prims << solid(box_x, box_y, box_size, box_size, bg)
        end

        brd = if @focused then t.colors[:border_focus]
              elsif @hovered then t.colors[:border_hover]
              elsif @checked then t.colors[:accent]
              else t.colors[:border]
              end
        prims << border(box_x, box_y, box_size, box_size, brd)

        if @focused
          prims << border(box_x - 2, box_y - 2, box_size + 4, box_size + 4,
                          t.colors[:border_focus])
        end

        if @checked
          fg = t.colors[:text_on_accent]
          s = box_size
          prims << { x: box_x + s * 0.2, y: box_y + s * 0.5,
                     x2: box_x + s * 0.4, y2: box_y + s * 0.25,
                     r: fg[:r], g: fg[:g], b: fg[:b], a: 255,
                     primitive_marker: :line }
          prims << { x: box_x + s * 0.4, y: box_y + s * 0.25,
                     x2: box_x + s * 0.8, y2: box_y + s * 0.75,
                     r: fg[:r], g: fg[:g], b: fg[:b], a: 255,
                     primitive_marker: :line }
        end

        unless @label_text.empty?
          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_primary]
          prims << label(box_x + box_size + 8, @y + @h / 2, @label_text, fg,
                         size_px: 20, font: t.font,
                         anchor_x: 0, anchor_y: 0.5)
        end

        prims
      end
    end
  end
end
