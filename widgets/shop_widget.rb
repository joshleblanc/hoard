# Hoard::Widgets::ShopWidget - Buy/Sell shop UI
#
# Displays a tabbed modal with a Buy tab (shop catalog) and a Sell tab
# (player inventory with sell prices). Click an item to get a confirmation
# dialog before buying/selling.
#
# Requires ConfirmationWidget on the same entity for the confirm dialog.
#
# Usage:
#   class Merchant < Hoard::Entity
#     widget Hoard::Widgets::ShopWidget.new
#     widget Hoard::Widgets::ConfirmationWidget.new
#     widget Hoard::Widgets::NotificationWidget.new
#   end
#
#   merchant.shop_widget.open!(catalog: [...], inventory: [...], gold: 500)
#
# Callbacks (sent to entity scripts):
#   :on_buy_item  (item, quantity)
#   :on_sell_item (item, quantity)

module Hoard
  module Widgets
    class ShopWidget < Widget
      attr_accessor :catalog, :inventory, :gold, :shop_name

      CELL_W    = 280
      CELL_H    = 52
      CELL_PAD  = 4
      MAX_ROWS  = 7

      def initialize
        super
        @visible   = false
        @catalog   = []
        @inventory = []
        @gold      = 0
        @shop_name = "Shop"
        @tab       = :buy
        @selected  = -1
        @hovered   = -1
        @scroll    = 0
      end



      def open!(catalog: nil, inventory: nil, gold: nil, shop_name: nil)
        @catalog   = catalog   if catalog
        @inventory = inventory if inventory
        @gold      = gold      if gold
        @shop_name = shop_name if shop_name
        @tab       = :buy
        @selected  = -1
        @scroll    = 0
        show!
      end

      def update
        return unless @visible
        kb = $args.inputs.keyboard
        mouse = $args.inputs.mouse

        if kb.key_down.escape
          hide!
          return
        end

        # Scroll
        wheel = mouse.wheel
        if wheel
          @scroll = (@scroll - wheel.y * 2).clamp(0, max_scroll)
        end

        # Click an item row
        if mouse.click && @hovered >= 0 && @hovered < current_items.length
          handle_item_click(@hovered)
        end
      end

      def render
        t = theme_ref
        out = $args.outputs[:ui]

        # Dim
        out.primitives << bg_solid(0, 0, 1280, 720, { r: 0, g: 0, b: 0 }, 180)

        # Panel
        pw = CELL_W + 60
        ph = CELL_H * MAX_ROWS + CELL_PAD * (MAX_ROWS + 1) + 100
        px = (1280 - pw) / 2
        py = (720 - ph) / 2

        out.primitives << bg_solid(px, py, pw, ph, t.colors[:bg_secondary])
        out.primitives << border_prim(px, py, pw, ph, t.colors[:border])

        # Title
        title_h = 34
        title_y = py + ph - title_h
        out.primitives << bg_solid(px + 1, title_y, pw - 2, title_h - 1, t.colors[:bg_surface])
        out.primitives << lbl(px + pw / 2, title_y + title_h / 2, @shop_name,
                              t.colors[:text_primary], 22, 0.5, 0.5)
        out.primitives << lbl(px + pw - 10, title_y + title_h / 2, "[ESC]",
                              t.colors[:text_disabled], 14, 1, 0.5)

        # Tabs
        render_tabs(t, px, title_y)

        # Gold display
        out.primitives << lbl(px + pw - 12, py + 16, "Gold: #{@gold}",
                              t.colors[:warning], 18, 1, 0)

        # Item list
        items = current_items
        list_top = title_y - 44
        list_left = px + 16

        @hovered = -1
        mouse = $args.inputs.mouse

        MAX_ROWS.times do |vi|
          i = vi + @scroll
          break if i >= items.length

          item = items[i]
          iy = list_top - vi * (CELL_H + CELL_PAD)
          ix = list_left

          hovered = mouse.inside_rect?({ x: ix, y: iy, w: CELL_W, h: CELL_H })
          @hovered = i if hovered
          selected = i == @selected

          cell_bg = if selected then t.colors[:bg_active]
                    elsif hovered then t.colors[:bg_hover]
                    else t.colors[:bg_primary]
                    end
          out.primitives << bg_solid(ix, iy, CELL_W, CELL_H, cell_bg)

          brd_color = selected ? t.colors[:accent] : t.colors[:border]
          out.primitives << border_prim(ix, iy, CELL_W, CELL_H, brd_color)

          # Icon
          icon = item_val(item, :icon)
          if icon
            out.primitives << { x: ix + 4, y: iy + 4, w: CELL_H - 8, h: CELL_H - 8, path: icon }
          else
            out.primitives << bg_solid(ix + 6, iy + 6, CELL_H - 12, CELL_H - 12, t.colors[:accent])
          end

          # Name
          name = item_val(item, :name, "???")
          text_x = ix + CELL_H + 4
          out.primitives << lbl(text_x, iy + CELL_H - 8, name,
                                t.colors[:text_primary], 18, 0, 1)

          # Description
          desc = item_val(item, :description, "")
          unless desc.empty?
            out.primitives << lbl(text_x, iy + 10, desc[0..35],
                                  t.colors[:text_disabled], 13, 0, 0)
          end

          # Price / quantity
          if @tab == :buy
            price = item_val(item, :buy_price, 0)
            affordable = @gold >= price
            price_color = affordable ? t.colors[:warning] : t.colors[:error]
            out.primitives << lbl(ix + CELL_W - 8, iy + CELL_H / 2, "#{price}g",
                                  price_color, 18, 1, 0.5)
          else
            qty = item_val(item, :quantity, 1)
            sell = item_val(item, :sell_price, 0)
            out.primitives << lbl(ix + CELL_W - 8, iy + CELL_H - 8, "x#{qty}",
                                  t.colors[:text_secondary], 14, 1, 1)
            if sell > 0
              out.primitives << lbl(ix + CELL_W - 8, iy + 10, "+#{sell}g",
                                    t.colors[:success], 14, 1, 0)
            end
          end
        end

        # Scroll indicators
        if @scroll > 0
          out.primitives << lbl(px + pw / 2, list_top + 12, "^ more ^",
                                t.colors[:text_disabled], 14, 0.5, 0)
        end
        if @scroll + MAX_ROWS < items.length
          bottom_y = list_top - MAX_ROWS * (CELL_H + CELL_PAD) + CELL_PAD
          out.primitives << lbl(px + pw / 2, bottom_y, "v more v",
                                t.colors[:text_disabled], 14, 0.5, 1)
        end
      end

      private

      def render_tabs(t, px, title_y)
        tab_y = title_y - 36
        tab_w = 100

        button :tab_buy,
          x: px + 16, y: tab_y,
          w: tab_w, h: 30,
          text: "Buy",
          style: @tab == :buy ? :primary : :default,
          size: :sm,
          on_click: ->(b) { @tab = :buy; @selected = -1; @scroll = 0 }

        button :tab_sell,
          x: px + 16 + tab_w + 8, y: tab_y,
          w: tab_w, h: 30,
          text: "Sell",
          style: @tab == :sell ? :primary : :default,
          size: :sm,
          on_click: ->(b) { @tab = :sell; @selected = -1; @scroll = 0 }
      end

      def handle_item_click(index)
        items = current_items
        item = items[index]
        return unless item

        @selected = index
        name = item_val(item, :name, "Item")

        cw = entity.respond_to?(:confirmation_widget) ? entity.confirmation_widget : nil
        unless cw
          # No confirmation widget -- just do the action directly
          execute_action(item)
          return
        end

        if @tab == :buy
          price = item_val(item, :buy_price, 0)
          if @gold < price
            notify("Can't Afford", "#{name} costs #{price}g", :error)
            return
          end
          cw.confirm(
            title:    "Buy Item",
            message:  "Buy #{name} for #{price}g?",
            yes_text: "Buy",
            no_text:  "Cancel",
            yes_style: :success,
            no_style:  :default,
            on_yes: -> {
              entity.send_to_scripts(:on_buy_item, item, 1)
              @gold -= price
              notify("Purchased", name, :success)
            }
          )
        else
          sell = item_val(item, :sell_price, 0)
          cw.confirm(
            title:    "Sell Item",
            message:  sell > 0 ? "Sell #{name} for #{sell}g?" : "Sell #{name}?",
            yes_text: "Sell",
            no_text:  "Cancel",
            yes_style: :warning,
            no_style:  :default,
            on_yes: -> {
              entity.send_to_scripts(:on_sell_item, item, 1)
              @gold += sell
              notify("Sold", name, :warning)
            }
          )
        end
      end

      def execute_action(item)
        name = item_val(item, :name, "Item")
        if @tab == :buy
          price = item_val(item, :buy_price, 0)
          return if @gold < price
          entity.send_to_scripts(:on_buy_item, item, 1)
          @gold -= price
          notify("Purchased", name, :success)
        else
          sell = item_val(item, :sell_price, 0)
          entity.send_to_scripts(:on_sell_item, item, 1)
          @gold += sell
          notify("Sold", name, :warning)
        end
      end

      def current_items
        @tab == :buy ? @catalog : @inventory
      end

      def max_scroll
        [current_items.length - MAX_ROWS, 0].max
      end

      def notify(title, detail, color_key)
        nw = entity.respond_to?(:notification_widget) ? entity.notification_widget : nil
        nw.notify(title, detail, color_key) if nw
      end

      def theme_ref
        $hoard_ui_theme || Hoard::Ui::Theme.new
      end

      def item_val(item, key, default = nil)
        if item.is_a?(Hash)
          item[key] || default
        elsif item.respond_to?(key)
          item.send(key) || default
        else
          default
        end
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
