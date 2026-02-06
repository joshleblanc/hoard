module Hoard
  module Ui
    class TextInput < Component
      attr_accessor :text, :placeholder, :on_change, :on_submit, :tooltip,
                    :max_length, :password

      def initialize(x:, y:, w: 200, h: nil, text: "", placeholder: "",
                     on_change: nil, on_submit: nil, max_length: nil,
                     password: false, tooltip: nil, **opts)
        @text = text
        @placeholder = placeholder
        @on_change = on_change
        @on_submit = on_submit
        @max_length = max_length
        @password = password
        @tooltip = tooltip
        @cursor_pos = text.length
        @cursor_blink_at = 0
        @key_repeat_timers = {}

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        h ||= t.size(:input_h)
        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        return unless @enabled

        mouse = args.inputs.mouse
        if mouse.click && @hovered
          # Focus is managed by Context#handle_click_focus -- don't call focus! here.
          @cursor_blink_at = Kernel.tick_count
          position_cursor_from_mouse(args)
        end

        return unless @focused
        handle_keyboard(args)
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        bg = @enabled ? t.colors[:bg_primary] : t.colors[:bg_disabled]
        prims << solid(@x, @y, @w, @h, bg)

        brd = if @focused then t.colors[:border_focus]
              elsif @hovered then t.colors[:border_hover]
              else t.colors[:border]
              end
        prims << border(@x, @y, @w, @h, brd)

        if @focused
          prims << border(@x - 1, @y - 1, @w + 2, @h + 2, t.colors[:border_focus], 100)
        end

        pad = 8
        display = display_text
        font_size = 20

        if display.empty? && !@placeholder.empty?
          prims << label(@x + pad, @y + @h / 2, @placeholder,
                         t.colors[:text_disabled],
                         size_px: font_size, font: t.font,
                         anchor_x: 0, anchor_y: 0.5)
        else
          color = @enabled ? t.colors[:text_primary] : t.colors[:text_disabled]
          prims << label(@x + pad, @y + @h / 2, display, color,
                         size_px: font_size, font: t.font,
                         anchor_x: 0, anchor_y: 0.5)
        end

        if @focused && cursor_visible?
          cursor_x = @x + pad + cursor_pixel_offset
          prims << solid(cursor_x, @y + 6, 2, @h - 12, t.colors[:text_primary])
        end

        prims
      end

      def value
        @text
      end

      def value=(new_text)
        @text = new_text
        @cursor_pos = @text.length
      end

      def clear
        @text = ""
        @cursor_pos = 0
        @on_change.call(self) if @on_change
      end

      private

      def display_text
        @password ? "*" * @text.length : @text
      end

      # Frames before key repeat starts, and frames between each repeat
      KEY_REPEAT_DELAY = 24
      KEY_REPEAT_RATE  = 3

      def key_action?(kb, key)
        if kb.key_down.send(key)
          @key_repeat_timers[key] = 0
          return true
        elsif kb.key_held.send(key)
          @key_repeat_timers[key] ||= 0
          @key_repeat_timers[key] += 1
          if @key_repeat_timers[key] >= KEY_REPEAT_DELAY &&
             (@key_repeat_timers[key] - KEY_REPEAT_DELAY) % KEY_REPEAT_RATE == 0
            return true
          end
        else
          @key_repeat_timers.delete(key)
        end
        false
      end

      def handle_keyboard(args)
        kb = args.inputs.keyboard

        if key_action?(kb, :backspace)
          if @cursor_pos > 0
            @text = @text[0...(@cursor_pos - 1)] + @text[@cursor_pos..]
            @cursor_pos -= 1
            @cursor_blink_at = Kernel.tick_count
            @on_change.call(self) if @on_change
          end
        end

        if key_action?(kb, :delete)
          if @cursor_pos < @text.length
            @text = @text[0...@cursor_pos] + @text[(@cursor_pos + 1)..]
            @cursor_blink_at = Kernel.tick_count
            @on_change.call(self) if @on_change
          end
        end

        if key_action?(kb, :left)
          @cursor_pos = [@cursor_pos - 1, 0].max
          @cursor_blink_at = Kernel.tick_count
        end
        if key_action?(kb, :right)
          @cursor_pos = [@cursor_pos + 1, @text.length].min
          @cursor_blink_at = Kernel.tick_count
        end

        if kb.key_down.home
          @cursor_pos = 0
          @cursor_blink_at = Kernel.tick_count
        end
        if kb.key_down.end
          @cursor_pos = @text.length
          @cursor_blink_at = Kernel.tick_count
        end

        if kb.key_down.enter
          @on_submit.call(self) if @on_submit
        end

        if kb.key_down.escape
          blur!
        end

        input_texts = args.inputs.text
        if input_texts && input_texts.length > 0
          input_texts.each do |char|
            next unless char
            next if char.length == 0
            next if char.ord < 32

            if @max_length.nil? || @text.length < @max_length
              @text = @text[0...@cursor_pos] + char + @text[@cursor_pos..]
              @cursor_pos += char.length
              @cursor_blink_at = Kernel.tick_count
              @on_change.call(self) if @on_change
            end
          end
        end
      end

      def cursor_visible?
        elapsed = Kernel.tick_count - @cursor_blink_at
        (elapsed / 30) % 2 == 0
      end

      def cursor_pixel_offset
        before_cursor = display_text[0...@cursor_pos] || ""
        $gtk ? $gtk.calcstringbox(before_cursor, 0)[0] : before_cursor.length * 10
      end

      def position_cursor_from_mouse(args)
        relative_x = args.inputs.mouse.x - @x - 8
        return @cursor_pos = 0 if relative_x <= 0

        display = display_text
        (0..display.length).each do |i|
          substr = display[0...i]
          w = $gtk ? $gtk.calcstringbox(substr, 0)[0] : substr.length * 10
          if w >= relative_x
            @cursor_pos = [i - 1, 0].max
            return
          end
        end
        @cursor_pos = display.length
      end
    end
  end
end
