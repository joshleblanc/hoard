module Hoard
  module Ui
    class Dropdown < Component
      attr_accessor :options, :selected_index, :placeholder, :on_change, :tooltip

      def initialize(x:, y:, w: 180, h: nil, options: [], selected_index: -1,
                     placeholder: "Select...", on_change: nil, tooltip: nil, **opts)
        @options = options
        @selected_index = selected_index
        @placeholder = placeholder
        @on_change = on_change
        @tooltip = tooltip
        @open = false
        @hover_index = -1

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        h ||= t.size(:input_h)
        super(x: x, y: y, w: w, h: h, **opts)
      end

      def selected_value
        @selected_index >= 0 && @selected_index < @options.length ? @options[@selected_index] : nil
      end

      def tick(args)
        return unless @visible
        mouse = args.inputs.mouse
        @hovered = mouse.inside_rect?(rect)

        unless @enabled
          @state = :disabled
          return
        end

        if @open
          handle_open_state(args)
        else
          @state = if @hovered && mouse.down then :active
                   elsif @hovered then :hover
                   elsif @focused then :focused
                   else :normal
                   end

          if (mouse.click && @hovered) ||
             (@focused && args.inputs.keyboard.key_down.enter)
            @open = true
            @hover_index = @selected_index
          end
        end

        if @focused && !@open
          kb = args.inputs.keyboard
          if kb.key_down.up
            @selected_index = [(@selected_index - 1), 0].max
            @on_change.call(self) if @on_change
          elsif kb.key_down.down
            @selected_index = [(@selected_index + 1), @options.length - 1].min
            @on_change.call(self) if @on_change
          end
        end
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        bg = case @state
             when :hover  then t.colors[:bg_hover]
             when :active then t.colors[:bg_active]
             when :disabled then t.colors[:bg_disabled]
             else t.colors[:bg_surface]
             end
        prims << solid(@x, @y, @w, @h, bg)

        brd = if @open || @focused then t.colors[:border_focus]
              elsif @hovered then t.colors[:border_hover]
              else t.colors[:border]
              end
        prims << border(@x, @y, @w, @h, brd)

        display = selected_value || @placeholder
        fg = selected_value ? t.colors[:text_primary] : t.colors[:text_disabled]
        fg = t.colors[:text_disabled] if @state == :disabled
        prims << label(@x + 8, @y + @h / 2, display, fg,
                       size_px: 20, font: t.font, anchor_x: 0, anchor_y: 0.5)

        arrow_x = @x + @w - 20
        arrow_y = @y + @h / 2
        arrow_c = t.colors[:text_secondary]
        if @open
          prims << { x: arrow_x - 4, y: arrow_y - 2, x2: arrow_x, y2: arrow_y + 4,
                     r: arrow_c[:r], g: arrow_c[:g], b: arrow_c[:b], primitive_marker: :line }
          prims << { x: arrow_x, y: arrow_y + 4, x2: arrow_x + 4, y2: arrow_y - 2,
                     r: arrow_c[:r], g: arrow_c[:g], b: arrow_c[:b], primitive_marker: :line }
        else
          prims << { x: arrow_x - 4, y: arrow_y + 2, x2: arrow_x, y2: arrow_y - 4,
                     r: arrow_c[:r], g: arrow_c[:g], b: arrow_c[:b], primitive_marker: :line }
          prims << { x: arrow_x, y: arrow_y - 4, x2: arrow_x + 4, y2: arrow_y + 2,
                     r: arrow_c[:r], g: arrow_c[:g], b: arrow_c[:b], primitive_marker: :line }
        end

        prims.concat(dropdown_list_prefab(t)) if @open

        prims
      end

      def close!
        @open = false
      end

      private

      def handle_open_state(args)
        mouse = args.inputs.mouse
        kb = args.inputs.keyboard

        if kb.key_down.up
          @hover_index = [(@hover_index - 1), 0].max
        elsif kb.key_down.down
          @hover_index = [(@hover_index + 1), @options.length - 1].min
        elsif kb.key_down.enter
          select_option(@hover_index)
          return
        elsif kb.key_down.escape
          @open = false
          return
        end

        if mouse.moved
          @options.each_with_index do |_opt, i|
            @hover_index = i if mouse.inside_rect?(option_rect_at(i))
          end
        end

        if mouse.click
          clicked_option = false
          @options.each_with_index do |_opt, i|
            if mouse.inside_rect?(option_rect_at(i))
              select_option(i)
              clicked_option = true
              break
            end
          end
          @open = false unless clicked_option
        end
      end

      def select_option(index)
        return if index < 0 || index >= @options.length
        old = @selected_index
        @selected_index = index
        @open = false
        @on_change.call(self) if old != index && @on_change
      end

      def option_rect_at(index)
        item_h = @h
        list_y = @y - (index + 1) * item_h
        { x: @x, y: list_y, w: @w, h: item_h }
      end

      def dropdown_list_prefab(t)
        prims = []
        return prims if @options.empty?

        item_h = @h
        total_h = @options.length * item_h
        list_y = @y - total_h

        prims << solid(@x, list_y, @w, total_h, t.colors[:bg_secondary])
        prims << border(@x, list_y, @w, total_h, t.colors[:border_focus])

        @options.each_with_index do |opt, i|
          oy = @y - (i + 1) * item_h

          if i == @hover_index
            prims << solid(@x + 1, oy + 1, @w - 2, item_h - 2, t.colors[:bg_hover])
          end

          if i == @selected_index
            prims << solid(@x + 1, oy + 1, 3, item_h - 2, t.colors[:accent])
          end

          fg = i == @hover_index ? t.colors[:text_primary] : t.colors[:text_secondary]
          prims << label(@x + 10, oy + item_h / 2, opt.to_s, fg,
                         size_px: 20, font: t.font, anchor_x: 0, anchor_y: 0.5)
        end

        prims
      end
    end
  end
end
