module Hoard
  module Ui
    class Label < Component
      attr_accessor :text, :color_key, :size_key, :align, :tooltip, :wrap_width

      def initialize(x:, y:, text: "", color_key: :text_primary, size_key: :size_md,
                     align: :left, wrap_width: nil, tooltip: nil, **opts)
        @text = text
        @color_key = color_key
        @size_key = size_key
        @align = align
        @wrap_width = wrap_width
        @tooltip = tooltip

        w = opts.delete(:w) || 0
        h = opts.delete(:h) || 0
        super(x: x, y: y, w: w, h: h, **opts)
      end

      def tick(args)
        return unless @visible
        if @tooltip
          mouse = args.inputs.mouse
          tw, th = text_dimensions
          hit = hit_rect(tw, th)
          @hovered = mouse.inside_rect?(hit)
        end
      end

      def prefab
        return [] unless @visible
        t = theme
        color = t.colors[@color_key] || t.colors[:text_primary]
        font = t.font
        size_px = t.font_size(@size_key)

        anchor_x = case @align
                   when :center then 0.5
                   when :right then 1.0
                   else 0.0
                   end

        if @wrap_width && @text.length > @wrap_width
          lines = wrap_text(@text, @wrap_width)
          prims = []
          lines.each_with_index do |line, i|
            prims << label(@x, @y - (i * (size_px + 4)), line, color,
                           size_px: size_px, font: font,
                           anchor_x: anchor_x, anchor_y: 1)
          end
          prims
        else
          [label(@x, @y, @text, color,
                 size_px: size_px, font: font,
                 anchor_x: anchor_x, anchor_y: 0.5)]
        end
      end

      private

      def text_dimensions
        $gtk ? $gtk.calcstringbox(@text, 0) : [@text.length * 10, 22]
      end

      def hit_rect(tw, th)
        case @align
        when :center then { x: @x - tw / 2, y: @y - th / 2, w: tw, h: th }
        when :right  then { x: @x - tw, y: @y - th / 2, w: tw, h: th }
        else              { x: @x, y: @y - th / 2, w: tw, h: th }
        end
      end

      def wrap_text(text, max_chars)
        words = text.split(' ')
        lines = []
        current_line = ""
        words.each do |word|
          test = current_line.empty? ? word : "#{current_line} #{word}"
          if test.length > max_chars && !current_line.empty?
            lines << current_line
            current_line = word
          else
            current_line = test
          end
        end
        lines << current_line unless current_line.empty?
        lines
      end
    end
  end
end
