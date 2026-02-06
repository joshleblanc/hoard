# Hoard::Widgets::ConfirmationWidget - Reusable Yes/No confirmation dialog
#
# Any system can request a confirmation. The dialog renders centered on
# :ui above everything else (via z_order), with a title, message, and Yes/No buttons.
#
# Usage:
#   entity.confirmation_widget.confirm(
#     title:   "Purchase Item",
#     message: "Buy Iron Sword for 150g?",
#     yes_text: "Buy",
#     no_text:  "Cancel",
#     on_yes: -> { do_purchase },
#     on_no:  -> { }  # optional
#   )

module Hoard
  module Widgets
    class ConfirmationWidget < Widget
      def initialize
        super
        @visible = false
        @title   = ""
        @message = ""
        @yes_text = "Yes"
        @no_text  = "No"
        @on_yes  = nil
        @on_no   = nil
        @yes_style = :success
        @no_style  = :danger
      end



      # Show the confirmation dialog. All options are keyword args.
      def confirm(title: "Confirm", message: "", yes_text: "Yes", no_text: "No",
                  yes_style: :success, no_style: :danger, on_yes: nil, on_no: nil)
        @title     = title
        @message   = message
        @yes_text  = yes_text
        @no_text   = no_text
        @yes_style = yes_style
        @no_style  = no_style
        @on_yes    = on_yes
        @on_no     = on_no
        show!
      end

      def update
        return unless @visible
        if $args.inputs.keyboard.key_down.escape
          do_no
        end
      end

      def render
        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        out = $args.outputs[:ui]

        # Dim
        out.primitives << bg_solid(0, 0, 1280, 720, { r: 0, g: 0, b: 0 }, 140)

        # Dialog box
        dw = 360
        dh = 160
        dx = (1280 - dw) / 2
        dy = (720 - dh) / 2

        out.primitives << bg_solid(dx, dy, dw, dh, t.colors[:bg_secondary])
        out.primitives << border_prim(dx, dy, dw, dh, t.colors[:border])

        # Title bar
        th = 32
        ty = dy + dh - th
        out.primitives << bg_solid(dx + 1, ty, dw - 2, th - 1, t.colors[:bg_surface])
        out.primitives << lbl(dx + dw / 2, ty + th / 2, @title,
                              t.colors[:text_primary], 20, 0.5, 0.5)

        # Message
        out.primitives << lbl(dx + dw / 2, dy + dh / 2 - 4, @message,
                              t.colors[:text_secondary], 18, 0.5, 0.5)

        # Buttons
        btn_w = 100
        btn_h = 32
        btn_y = dy + 14
        gap = 20

        button :confirm_yes,
          x: dx + dw / 2 - btn_w - gap / 2,
          y: btn_y,
          w: btn_w, h: btn_h,
          text: @yes_text,
          style: @yes_style,
          size: :sm,
          on_click: ->(b) { do_yes }

        button :confirm_no,
          x: dx + dw / 2 + gap / 2,
          y: btn_y,
          w: btn_w, h: btn_h,
          text: @no_text,
          style: @no_style,
          size: :sm,
          on_click: ->(b) { do_no }
      end

      private

      def do_yes
        cb = @on_yes
        hide!
        cb.call if cb
      end

      def do_no
        cb = @on_no
        hide!
        cb.call if cb
      end

      def bg_solid(x, y, w, h, color, alpha = 255)
        { x: x, y: y, w: w, h: h, path: :solid,
          r: color[:r], g: color[:g], b: color[:b], a: alpha }
      end

      def border_prim(x, y, w, h, color, alpha = 255)
        { x: x, y: y, w: w, h: h,
          r: color[:r], g: color[:g], b: color[:b], a: alpha,
          primitive_marker: :border }
      end

      def lbl(x, y, text, color, size_px, ax = 0, ay = 0)
        { x: x, y: y, text: text.to_s, size_px: size_px,
          anchor_x: ax, anchor_y: ay,
          r: color[:r], g: color[:g], b: color[:b], a: color[:a] || 255 }
      end
    end
  end
end
