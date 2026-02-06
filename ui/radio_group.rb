module Hoard
  module Ui
    class RadioGroup < Component
      attr_accessor :options, :selected_index, :on_change, :tooltip, :orientation

      def initialize(x:, y:, options: [], selected_index: 0, on_change: nil,
                     orientation: :vertical, tooltip: nil, **opts)
        @options = options
        @selected_index = selected_index
        @on_change = on_change
        @orientation = orientation
        @tooltip = tooltip
        @hover_option = -1

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        item_h = 28
        if @orientation == :vertical
          w = opts.delete(:w) || 200
          h = opts.delete(:h) || options.length * item_h
        else
          w = opts.delete(:w) || options.length * 120
          h = opts.delete(:h) || item_h
        end

        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        return unless @enabled

        mouse = args.inputs.mouse
        @hover_option = -1

        @options.each_with_index do |_opt, i|
          r = option_rect(i)
          if mouse.inside_rect?(r)
            @hover_option = i
            select!(i) if mouse.click
          end
        end

        if @focused
          kb = args.inputs.keyboard
          if @orientation == :vertical
            select!((@selected_index - 1) % @options.length) if kb.key_down.up
            select!((@selected_index + 1) % @options.length) if kb.key_down.down
          else
            select!((@selected_index - 1) % @options.length) if kb.key_down.left
            select!((@selected_index + 1) % @options.length) if kb.key_down.right
          end
        end
      end

      def selected_value
        @selected_index >= 0 ? @options[@selected_index] : nil
      end

      def select!(index)
        return if index < 0 || index >= @options.length
        old = @selected_index
        @selected_index = index
        @on_change.call(self) if old != index && @on_change
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        radio_size = 16
        dot_size = 8

        @options.each_with_index do |opt, i|
          r = option_rect(i)
          selected = i == @selected_index
          hovered = i == @hover_option

          cy = r[:y] + r[:h] / 2

          prims << solid(r[:x], cy - radio_size / 2, radio_size, radio_size,
                         selected ? t.colors[:accent] : t.colors[:bg_primary])
          circle_color = if selected then t.colors[:accent]
                         elsif hovered then t.colors[:border_hover]
                         else t.colors[:border]
                         end
          prims << border(r[:x], cy - radio_size / 2, radio_size, radio_size, circle_color)

          if selected
            dot_offset = (radio_size - dot_size) / 2
            prims << solid(r[:x] + dot_offset, cy - dot_size / 2,
                           dot_size, dot_size, t.colors[:text_on_accent])
          end

          if @focused && selected
            prims << border(r[:x] - 2, cy - radio_size / 2 - 2,
                            radio_size + 4, radio_size + 4,
                            t.colors[:border_focus])
          end

          fg = @state == :disabled ? t.colors[:text_disabled] : t.colors[:text_primary]
          prims << label(r[:x] + radio_size + 8, cy, opt.to_s, fg,
                         size_px: 20, font: t.font, anchor_x: 0, anchor_y: 0.5)
        end

        prims
      end

      private

      def option_rect(index)
        item_h = 28
        if @orientation == :vertical
          { x: @x, y: @y + @h - (index + 1) * item_h, w: @w, h: item_h }
        else
          item_w = @w / @options.length
          { x: @x + index * item_w, y: @y, w: item_w, h: @h }
        end
      end
    end
  end
end
