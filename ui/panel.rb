module Hoard
  module Ui
    class Panel < Component
      attr_accessor :title, :children, :padding, :bg_color_key, :border_color_key, :tooltip

      def initialize(x:, y:, w:, h:, title: nil, padding: nil,
                     bg_color_key: :bg_secondary, border_color_key: :border,
                     tooltip: nil, **opts)
        @title = title
        @children = []
        @bg_color_key = bg_color_key
        @border_color_key = border_color_key
        @tooltip = tooltip

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        @padding = padding || t.size(:padding_md)

        super(x: x, y: y, w: w, h: h, **opts)
      end

      def add(child)
        @children << child
        child
      end

      def remove(child)
        @children.delete(child)
      end

      def clear_children
        @children.clear
      end

      def tick(args)
        return unless @visible
        super(args)
        # Children are ticked by the Context -- Panel is visual only.
      end

      def content_rect
        title_h = @title ? 30 : 0
        {
          x: @x + @padding,
          y: @y + @padding,
          w: @w - @padding * 2,
          h: @h - @padding * 2 - title_h
        }
      end

      def prefab
        return [] unless @visible
        t = theme
        prims = []

        prims << solid(@x, @y, @w, @h, t.colors[@bg_color_key])
        prims << border(@x, @y, @w, @h, t.colors[@border_color_key])

        if @title
          title_h = 30
          title_y = @y + @h - title_h
          prims << solid(@x + 1, title_y, @w - 2, title_h - 1, t.colors[:bg_surface])
          prims << label(@x + @padding, title_y + title_h / 2, @title,
                         t.colors[:text_primary],
                         size_px: 18, font: t.font,
                         anchor_x: 0, anchor_y: 0.5)
        end

        @children.each do |child|
          next unless child.visible
          prims.concat(child.prefab)
        end

        prims
      end
    end
  end
end
