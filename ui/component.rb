module Hoard
  module Ui
    class Component
      attr_accessor :x, :y, :w, :h, :id, :visible, :enabled, :on_focus, :on_blur
      attr_reader :focused, :hovered, :state

      def initialize(x:, y:, w:, h:, id: nil, visible: true, enabled: true, **_rest)
        @x = x
        @y = y
        @w = w
        @h = h
        @id = id || object_id
        @visible = visible
        @enabled = enabled
        @focused = false
        @hovered = false
        @state = :normal
      end

      def tick(args)
        return unless @visible
        update_interaction_state(args)
      end

      def prefab
        []
      end

      def rect
        { x: @x, y: @y, w: @w, h: @h }
      end

      def focus!
        return if @focused
        @focused = true
        @on_focus.call(self) if @on_focus
      end

      def blur!
        return unless @focused
        @focused = false
        @on_blur.call(self) if @on_blur
      end

      def enable!
        @enabled = true
      end

      def disable!
        @enabled = false
        @state = :disabled
      end

      def show!
        @visible = true
      end

      def hide!
        @visible = false
      end

      private

      def update_interaction_state(args)
        unless @enabled
          @state = :disabled
          @hovered = false
          return
        end

        mouse = args.inputs.mouse
        @hovered = mouse.inside_rect?(rect)

        if @hovered && mouse.down
          @state = :active
        elsif @hovered
          @state = :hover
        elsif @focused
          @state = :focused
        else
          @state = :normal
        end
      end

      def theme
        $hoard_ui_theme || Hoard::Ui::Theme.new
      end

      def solid(x, y, w, h, color, alpha = 255)
        { x: x, y: y, w: w, h: h, path: :solid,
          r: color[:r], g: color[:g], b: color[:b], a: alpha }
      end

      def border(x, y, w, h, color, alpha = 255)
        { x: x, y: y, w: w, h: h,
          r: color[:r], g: color[:g], b: color[:b], a: alpha,
          primitive_marker: :border }
      end

      def label(x, y, text, color, size_px: nil, font: nil, anchor_x: 0, anchor_y: 0)
        l = { x: x, y: y, text: text.to_s,
              r: color[:r], g: color[:g], b: color[:b], a: color[:a] || 255,
              anchor_x: anchor_x, anchor_y: anchor_y }
        l[:size_px] = size_px if size_px
        l[:font] = font if font
        l
      end
    end
  end
end
