module Hoard
  module Ui
    class Theme
      attr_reader :colors, :fonts, :sizes

      def initialize
        @colors = default_colors
        @fonts  = default_fonts
        @sizes  = default_sizes
      end

      def default_colors
        {
          bg_primary:   { r: 35,  g: 39,  b: 46  },
          bg_secondary: { r: 48,  g: 54,  b: 63  },
          bg_surface:   { r: 58,  g: 65,  b: 77  },
          bg_hover:     { r: 68,  g: 76,  b: 90  },
          bg_active:    { r: 78,  g: 86,  b: 100 },
          bg_disabled:  { r: 40,  g: 44,  b: 52  },

          accent:          { r: 97,  g: 175, b: 239 },
          accent_hover:    { r: 120, g: 190, b: 245 },
          accent_active:   { r: 75,  g: 155, b: 220 },
          accent_disabled: { r: 70,  g: 100, b: 140 },

          success:   { r: 80,  g: 200, b: 120 },
          warning:   { r: 230, g: 180, b: 60  },
          error:     { r: 220, g: 80,  b: 80  },

          text_primary:   { r: 220, g: 223, b: 228 },
          text_secondary: { r: 150, g: 155, b: 165 },
          text_disabled:  { r: 90,  g: 95,  b: 105 },
          text_on_accent: { r: 15,  g: 20,  b: 30  },

          border:        { r: 70,  g: 78,  b: 90  },
          border_hover:  { r: 90,  g: 100, b: 115 },
          border_focus:  { r: 97,  g: 175, b: 239 },

          shadow:      { r: 0, g: 0, b: 0 },
          overlay:     { r: 0, g: 0, b: 0 },
          transparent: { r: 0, g: 0, b: 0, a: 0 },
        }
      end

      def default_fonts
        {
          default: nil,
          size_xs:  16,
          size_sm:  18,
          size_md:  22,
          size_lg:  28,
          size_xl:  36,
          size_xxl: 48,
        }
      end

      def default_sizes
        {
          padding_xs: 4,
          padding_sm: 8,
          padding_md: 12,
          padding_lg: 16,
          padding_xl: 24,

          border_width: 1,

          button_h:      40,
          input_h:       36,
          checkbox_size: 22,
          toggle_w:      48,
          toggle_h:      26,
          slider_h:      6,
          slider_thumb:  18,
          progress_h:    8,

          anim_fast:   8,
          anim_normal: 15,
          anim_slow:   30,
        }
      end

      def color(name, alpha = 255)
        c = @colors[name]
        return { r: 255, g: 0, b: 255, a: alpha } unless c
        { r: c[:r], g: c[:g], b: c[:b], a: alpha }
      end

      def font
        @fonts[:default]
      end

      def font_size(size_key = :size_md)
        @fonts[size_key] || @fonts[:size_md]
      end

      def size(key)
        @sizes[key] || 0
      end

      def set_color(name, r:, g:, b:)
        @colors[name] = { r: r, g: g, b: b }
      end

      def set_font(path)
        @fonts[:default] = path
      end

      def self.light
        theme = new
        theme.instance_variable_set(:@colors, {
          bg_primary:   { r: 245, g: 245, b: 248 },
          bg_secondary: { r: 235, g: 236, b: 240 },
          bg_surface:   { r: 255, g: 255, b: 255 },
          bg_hover:     { r: 228, g: 230, b: 235 },
          bg_active:    { r: 218, g: 220, b: 228 },
          bg_disabled:  { r: 235, g: 236, b: 240 },

          accent:          { r: 55,  g: 120, b: 220 },
          accent_hover:    { r: 70,  g: 135, b: 235 },
          accent_active:   { r: 40,  g: 100, b: 200 },
          accent_disabled: { r: 150, g: 180, b: 210 },

          success:   { r: 50,  g: 170, b: 90  },
          warning:   { r: 210, g: 160, b: 40  },
          error:     { r: 200, g: 60,  b: 60  },

          text_primary:   { r: 30,  g: 33,  b: 40  },
          text_secondary: { r: 100, g: 105, b: 115 },
          text_disabled:  { r: 170, g: 175, b: 185 },
          text_on_accent: { r: 255, g: 255, b: 255 },

          border:        { r: 200, g: 205, b: 215 },
          border_hover:  { r: 170, g: 175, b: 190 },
          border_focus:  { r: 55,  g: 120, b: 220 },

          shadow:      { r: 0, g: 0, b: 0 },
          overlay:     { r: 0, g: 0, b: 0 },
          transparent: { r: 0, g: 0, b: 0, a: 0 },
        })
        theme
      end
    end
  end
end
