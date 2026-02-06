# Hoard::Widgets::InventoryWidget - Grid-based inventory UI
#
# Works with Hoard::Scripts::InventoryScript / InventorySpecScript.
# Shows items in a grid with hover tooltips and a click context menu
# (Use / Examine / Drop). Renders on the :ui_overlay layer as a modal.
#
# Usage:
#   class Player < Hoard::Entity
#     script Hoard::Scripts::InventoryScript.new(20)
#     widget Hoard::Widgets::InventoryWidget.new
#     widget Hoard::Widgets::NotificationWidget.new  # optional, for pickup toasts
#   end
#
#   # Toggle with a key:
#   entity.inventory_widget.toggle! if args.inputs.keyboard.key_down.i

module Hoard
  module Widgets
    class InventoryWidget < Widget
      attr_accessor :slots, :size

      CELL_SIZE = 56
      CELL_PAD  = 6
      COLS      = 5

      def initialize
        super
        @visible = false
        @slots = []
        @size = 20
        @hovered_index = -1
        @context_index = -1
        @context_open = false
      end

      # Render to overlay so it draws above all other UI
      def _ui_context
        @_ui_ctx ||= Hoard::Ui::Context.new(
          theme: $hoard_ui_theme || Hoard::Ui::Theme.new,
          render_target: :ui_overlay
        )
      end

      def update
        return unless @visible
        handle_input
      end

      def render
        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        out = $args.outputs[:ui_overlay]

        # Dim overlay
        out.primitives << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 180 }

        rows = (@size.to_f / COLS).ceil
        grid_w = COLS * (CELL_SIZE + CELL_PAD) + CELL_PAD
        grid_h = rows * (CELL_SIZE + CELL_PAD) + CELL_PAD
        panel_w = grid_w + 24
        panel_h = grid_h + 60  # title + padding
        panel_x = (1280 - panel_w) / 2
        panel_y = (720 - panel_h) / 2

        # Panel background
        out.primitives << bg_solid(panel_x, panel_y, panel_w, panel_h, t.colors[:bg_secondary])
        out.primitives << border_prim(panel_x, panel_y, panel_w, panel_h, t.colors[:border])

        # Title bar
        title_h = 34
        title_y = panel_y + panel_h - title_h
        out.primitives << bg_solid(panel_x + 1, title_y, panel_w - 2, title_h - 1, t.colors[:bg_surface])
        out.primitives << {
          x: panel_x + panel_w / 2, y: title_y + title_h / 2,
          text: "Inventory", size_px: 22,
          anchor_x: 0.5, anchor_y: 0.5,
          r: t.colors[:text_primary][:r], g: t.colors[:text_primary][:g], b: t.colors[:text_primary][:b]
        }

        # Close hint
        out.primitives << {
          x: panel_x + panel_w - 10, y: title_y + title_h / 2,
          text: "[ESC]", size_px: 14,
          anchor_x: 1, anchor_y: 0.5,
          r: t.colors[:text_disabled][:r], g: t.colors[:text_disabled][:g], b: t.colors[:text_disabled][:b]
        }

        # Grid
        mouse = $args.inputs.mouse
        grid_left = panel_x + 12
        grid_top  = title_y - CELL_PAD
        stride    = CELL_SIZE + CELL_PAD
        @hovered_index = -1

        rows = (@size.to_f / COLS).ceil
        rows.times do |row|
          COLS.times do |col|
            i = row * COLS + col
            break if i >= @size

            cx = grid_left + col * stride
            cy = grid_top - row * stride - CELL_SIZE

          slot = @slots[i] if i < @slots.length
          hovered = mouse.inside_rect?({ x: cx, y: cy, w: CELL_SIZE, h: CELL_SIZE })
          @hovered_index = i if hovered

          # Cell background
          cell_bg = if hovered then t.colors[:bg_hover]
                    else t.colors[:bg_primary]
                    end
          out.primitives << bg_solid(cx, cy, CELL_SIZE, CELL_SIZE, cell_bg)
          out.primitives << border_prim(cx, cy, CELL_SIZE, CELL_SIZE, t.colors[:border])

          next unless slot

          # Item icon (sprite if available, otherwise colored square)
          icon = slot_val(slot, :icon)
          if icon
            out.primitives << {
              x: cx + 4, y: cy + 4, w: CELL_SIZE - 8, h: CELL_SIZE - 8,
              path: icon
            }
          else
            out.primitives << bg_solid(cx + 8, cy + 8, CELL_SIZE - 16, CELL_SIZE - 16, t.colors[:accent])
          end

          # Quantity badge
          qty = slot_val(slot, :quantity, 1)
          if qty > 1
            out.primitives << {
              x: cx + CELL_SIZE - 4, y: cy + 4,
              text: qty.to_s, size_px: 14,
              anchor_x: 1, anchor_y: 0,
              r: t.colors[:text_primary][:r], g: t.colors[:text_primary][:g], b: t.colors[:text_primary][:b]
            }
          end
          end
        end

        # Tooltip on hover
        if @hovered_index >= 0 && @hovered_index < @slots.length && !@context_open
          render_tooltip(out, t, @slots[@hovered_index])
        end

        # Context menu
        if @context_open && @context_index >= 0 && @context_index < @slots.length
          render_context_menu(t)
        end
      end

      private

      def handle_input
        mouse = $args.inputs.mouse
        kb = $args.inputs.keyboard

        # ESC closes
        if kb.key_down.escape
          if @context_open
            @context_open = false
          else
            hide!
          end
          return
        end

        # Click
        if mouse.click
          if @context_open
            # Check if click is on a context menu button -- handled by UI components
            # If click is outside context menu, close it
            ctx_comp = find_component(:ctx_use) || find_component(:ctx_drop)
            unless ctx_comp && mouse.inside_rect?(context_menu_rect)
              @context_open = false
            end
          elsif @hovered_index >= 0 && @hovered_index < @slots.length
            @context_index = @hovered_index
            @context_open = true
            @context_x = mouse.x
            @context_y = mouse.y
          end
        end
      end

      def context_menu_rect
        w = 130
        h = 100
        { x: @context_x, y: @context_y - h, w: w, h: h }
      end

      def render_tooltip(out, t, slot)
        return unless slot
        name = slot_val(slot, :name, "???")
        desc = slot_val(slot, :description, "")

        mx = $args.inputs.mouse.x + 16
        my = $args.inputs.mouse.y + 16

        tw = 220
        th = desc.empty? ? 34 : 58

        # Clamp to screen
        mx = 1280 - tw - 4 if mx + tw > 1276
        my = th + 4 if my < th + 4

        out.primitives << bg_solid(mx, my - th, tw, th, t.colors[:bg_surface], 240)
        out.primitives << border_prim(mx, my - th, tw, th, t.colors[:border])

        out.primitives << {
          x: mx + 8, y: my - 6,
          text: name.to_s, size_px: 18,
          anchor_x: 0, anchor_y: 1,
          r: t.colors[:text_primary][:r], g: t.colors[:text_primary][:g], b: t.colors[:text_primary][:b]
        }

        unless desc.empty?
          out.primitives << {
            x: mx + 8, y: my - 28,
            text: desc.to_s[0..40], size_px: 14,
            anchor_x: 0, anchor_y: 1,
            r: t.colors[:text_secondary][:r], g: t.colors[:text_secondary][:g], b: t.colors[:text_secondary][:b]
          }
        end
      end

      def render_context_menu(t)
        slot = @slots[@context_index]
        return unless slot

        item_name = slot_val(slot, :name, "Item")

        actions = []
        actions << { id: :use,     label: "Use" }
        actions << { id: :examine, label: "Examine" }
        actions << { id: :drop,    label: "Drop",    style: :danger }

        menu_w = 130
        item_h = 32
        menu_h = actions.length * item_h + 8
        mx = @context_x
        my = @context_y

        # Clamp
        mx = 1280 - menu_w - 4 if mx + menu_w > 1276
        my = menu_h + 4 if my < menu_h + 4

        actions.each_with_index do |action, i|
          btn_style = action[:style] || :ghost
          button :"ctx_#{action[:id]}",
            x: mx, y: my - (i + 1) * item_h,
            w: menu_w, h: item_h - 2,
            text: action[:label],
            style: btn_style,
            size: :sm,
            on_click: ->(b) { handle_action(action[:id], @context_index) }
        end
      end

      def handle_action(action_id, index)
        slot = @slots[index]
        return unless slot
        @context_open = false

        item_name = slot_val(slot, :name, "Item")

        case action_id
        when :use
          entity.send_to_scripts(:on_use_item, slot)
          notify("Used", item_name, :accent)
        when :examine
          desc = slot_val(slot, :description, "Nothing special.")
          notify("Examine", "#{item_name}: #{desc}", :text_primary)
        when :drop
          entity.send_to_scripts(:on_drop_item, slot)
          notify("Dropped", item_name, :warning)
        end
      end

      def notify(title, detail, color_key)
        nw = entity.respond_to?(:notification_widget) ? entity.notification_widget : nil
        nw.notify(title, detail, color_key) if nw
      end

      # Read a field from a slot (works with hashes, structs, or objects)
      def slot_val(slot, key, default = nil)
        if slot.is_a?(Hash)
          slot[key] || default
        elsif slot.respond_to?(key)
          slot.send(key) || default
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
    end
  end
end
