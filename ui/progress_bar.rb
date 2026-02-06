module Hoard
  module Ui
    class ProgressBar < Component
      attr_accessor :value, :max, :label_text, :show_percentage, :color_key, :tooltip

      def initialize(x:, y:, w: 200, h: nil, value: 0, max: 100,
                     label_text: "", show_percentage: true,
                     color_key: :accent, tooltip: nil, **opts)
        @value = value
        @max = max
        @label_text = label_text
        @show_percentage = show_percentage
        @color_key = color_key
        @tooltip = tooltip
        @display_value = value.to_f

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        h ||= t.size(:progress_h) + 20
        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        super(args)
        @display_value = @display_value.lerp(@value.to_f, 0.15)
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        bar_h = t.size(:progress_h)
        bar_y = @y + (@h - bar_h) / 2

        prims << solid(@x, bar_y, @w, bar_h, t.colors[:bg_surface])
        prims << border(@x, bar_y, @w, bar_h, t.colors[:border])

        pct = @max > 0 ? (@display_value / @max.to_f).clamp(0.0, 1.0) : 0
        fill_w = (@w * pct).to_i
        fill_color = t.colors[@color_key] || t.colors[:accent]
        prims << solid(@x, bar_y, fill_w, bar_h, fill_color) if fill_w > 0

        unless @label_text.empty?
          prims << label(@x, bar_y + bar_h + 4, @label_text, t.colors[:text_primary],
                         size_px: 16, font: t.font, anchor_x: 0, anchor_y: 0)
        end

        if @show_percentage
          pct_text = "#{(pct * 100).to_i}%"
          prims << label(@x + @w, bar_y + bar_h + 4, pct_text, t.colors[:text_secondary],
                         size_px: 16, font: t.font, anchor_x: 1, anchor_y: 0)
        end

        prims
      end
    end
  end
end
