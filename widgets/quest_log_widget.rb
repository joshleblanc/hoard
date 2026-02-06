# Hoard::Widgets::QuestLogWidget - Quest browser with expandable tree sidebar
#
# Left side: scrollable tree of quests. Click a branch to expand/collapse.
# Click a leaf to show details on the right. Infinite nesting supported.
#
# Toggle visibility with show!/hide!/toggle!.

module Hoard
  module Widgets
    class QuestLogWidget < Widget
      SIDEBAR_W  = 280
      ROW_H      = 28
      INDENT     = 16
      PANEL_X    = 120
      PANEL_Y    = 60
      PANEL_W    = 1040
      PANEL_H    = 600
      TITLE_H    = 34

      def initialize
        super
        @visible = false
        @selected_id = nil
        @sidebar_scroll = 0
      end

      def update
        return unless @visible
        if $args.inputs.keyboard.key_down.escape
          hide!
          return
        end

        wheel = $args.inputs.mouse.wheel
        if wheel
          @sidebar_scroll = (@sidebar_scroll - wheel.y * 2).to_i
          @sidebar_scroll = [@sidebar_scroll, 0].max
        end
      end

      def render
        mgr = quest_manager
        return unless mgr

        t = $hoard_ui_theme || Hoard::Ui::Theme.new
        out = $args.outputs[:ui]

        # Dim overlay
        out.primitives << bg_solid(0, 0, 1280, 720, { r: 0, g: 0, b: 0 }, 180)

        # Panel background
        out.primitives << bg_solid(PANEL_X, PANEL_Y, PANEL_W, PANEL_H, t.colors[:bg_secondary])
        out.primitives << border_prim(PANEL_X, PANEL_Y, PANEL_W, PANEL_H, t.colors[:border])

        # Title bar
        title_y = PANEL_Y + PANEL_H - TITLE_H
        out.primitives << bg_solid(PANEL_X + 1, title_y, PANEL_W - 2, TITLE_H - 1, t.colors[:bg_surface])
        out.primitives << lbl(PANEL_X + PANEL_W / 2, title_y + TITLE_H / 2,
                              "Quest Log  (Score: #{mgr.score})",
                              t.colors[:text_primary], 22, 0.5, 0.5)
        out.primitives << lbl(PANEL_X + PANEL_W - 10, title_y + TITLE_H / 2,
                              "[ESC]", t.colors[:text_disabled], 14, 1, 0.5)

        # Sidebar divider
        sidebar_right = PANEL_X + SIDEBAR_W
        content_top = title_y
        content_bottom = PANEL_Y
        out.primitives << border_prim(sidebar_right, content_bottom, 1, content_top - content_bottom, t.colors[:border])

        # Sidebar: render the tree
        render_sidebar(mgr, t, out, content_top, content_bottom)

        # Detail pane (right side)
        render_detail(mgr, t, out, content_top, sidebar_right)
      end

      def on_quest_complete(quest); end

      private

      # ------------------------------------------------------------------
      # Sidebar tree
      # ------------------------------------------------------------------

      def render_sidebar(mgr, t, out, content_top, content_bottom)
        mouse = $args.inputs.mouse

        # Flatten the visible tree into rows
        rows = []
        mgr.roots.each { |root| collect_visible_rows(root, 0, rows) }

        # Clamp scroll
        visible_h = content_top - content_bottom
        max_visible = (visible_h / ROW_H).to_i
        max_scroll = [rows.length - max_visible, 0].max
        @sidebar_scroll = @sidebar_scroll.clamp(0, max_scroll)

        rows.each_with_index do |row, vi|
          ri = vi - @sidebar_scroll
          next if ri < 0
          break if ri >= max_visible

          quest = row[:quest]
          depth = row[:depth]

          ry = content_top - (ri + 1) * ROW_H
          rx = PANEL_X + 6 + depth * INDENT
          rw = SIDEBAR_W - 12 - depth * INDENT

          # Hit test
          hit_rect = { x: PANEL_X, y: ry, w: SIDEBAR_W, h: ROW_H }
          hovered = mouse.inside_rect?(hit_rect)
          selected = @selected_id == quest.id

          # Background
          if selected
            out.primitives << bg_solid(PANEL_X + 1, ry, SIDEBAR_W - 2, ROW_H, t.colors[:bg_active])
          elsif hovered
            out.primitives << bg_solid(PANEL_X + 1, ry, SIDEBAR_W - 2, ROW_H, t.colors[:bg_hover])
          end

          # Click handling
          if hovered && mouse.click
            if quest.branch?
              quest.expanded = !quest.expanded
            else
              @selected_id = quest.id
            end
          end

          # Expand/collapse indicator for branches
          if quest.branch?
            arrow = quest.expanded ? "v" : ">"
            out.primitives << lbl(rx, ry + ROW_H / 2, arrow,
                                  t.colors[:text_disabled], 14, 0, 0.5)
            rx += 14
          end

          # Name
          name_color = if quest.complete? then t.colors[:success]
                       elsif !quest.active then t.colors[:text_disabled]
                       elsif selected then t.colors[:accent]
                       else t.colors[:text_primary]
                       end
          out.primitives << lbl(rx, ry + ROW_H / 2, quest.name,
                                name_color, 16, 0, 0.5)

          # Progress/count on right side
          if quest.branch?
            count_text = "#{quest.completed_count}/#{quest.total_count}"
            out.primitives << lbl(PANEL_X + SIDEBAR_W - 10, ry + ROW_H / 2,
                                  count_text, t.colors[:text_disabled], 13, 1, 0.5)
          elsif quest.leaf? && !quest.complete?
            pct_text = "#{quest.progress_percent}%"
            out.primitives << lbl(PANEL_X + SIDEBAR_W - 10, ry + ROW_H / 2,
                                  pct_text, t.colors[:text_secondary], 13, 1, 0.5)
          elsif quest.complete?
            out.primitives << lbl(PANEL_X + SIDEBAR_W - 10, ry + ROW_H / 2,
                                  "done", t.colors[:success], 13, 1, 0.5)
          end
        end

        # Scroll indicators
        if @sidebar_scroll > 0
          out.primitives << lbl(PANEL_X + SIDEBAR_W / 2, content_top - 4,
                                "^ scroll ^", t.colors[:text_disabled], 12, 0.5, 1)
        end
        if @sidebar_scroll + max_visible < rows.length
          out.primitives << lbl(PANEL_X + SIDEBAR_W / 2, content_bottom + 4,
                                "v scroll v", t.colors[:text_disabled], 12, 0.5, 0)
        end
      end

      # Recursively collect visible tree rows (respecting expanded state)
      def collect_visible_rows(quest, depth, rows)
        rows << { quest: quest, depth: depth }
        if quest.branch? && quest.expanded
          sorted = quest.children.sort_by { |c| [c.complete? ? 1 : 0, c.active ? 0 : 1, c.index] }
          sorted.each { |child| collect_visible_rows(child, depth + 1, rows) }
        end
      end

      # ------------------------------------------------------------------
      # Detail pane
      # ------------------------------------------------------------------

      def render_detail(mgr, t, out, content_top, detail_left)
        detail_x = detail_left + 20
        detail_w = PANEL_X + PANEL_W - detail_x - 20

        selected = @selected_id ? mgr.quest(@selected_id) : nil

        if selected && selected.leaf?
          render_leaf_detail(selected, mgr, t, out, detail_x, content_top)
        elsif selected && selected.branch?
          render_branch_detail(selected, t, out, detail_x, content_top)
        else
          render_overview(mgr, t, out, detail_x, content_top)
        end
      end

      def render_overview(mgr, t, out, dx, top)
        out.primitives << lbl(dx, top - 20, "Recently Completed",
                              t.colors[:text_primary], 24, 0, 1)

        recent = mgr.recently_completed(8)
        recent.each_with_index do |q, i|
          out.primitives << lbl(dx, top - 52 - i * 26,
                                "#{q.score}pts  #{q.name}",
                                t.colors[:text_secondary], 16, 0, 1)
        end

        if recent.empty?
          out.primitives << lbl(dx, top - 52, "No quests completed yet.",
                                t.colors[:text_disabled], 16, 0, 1)
        end
      end

      def render_branch_detail(quest, t, out, dx, top)
        out.primitives << lbl(dx, top - 20, quest.name,
                              t.colors[:accent], 24, 0, 1)

        unless quest.description.empty?
          out.primitives << lbl(dx, top - 48, quest.description,
                                t.colors[:text_secondary], 16, 0, 1)
        end

        out.primitives << lbl(dx, top - 80,
                              "#{quest.completed_count}/#{quest.total_count} completed  (#{quest.progress_percent}%)",
                              t.colors[:text_primary], 18, 0, 1)

        # List direct children
        quest.children.sort_by { |c| [c.complete? ? 1 : 0, c.index] }.each_with_index do |child, i|
          cy = top - 115 - i * 26
          break if cy < PANEL_Y + 10

          status = child.complete? ? "[done]" : "#{child.progress_percent}%"
          color = child.complete? ? t.colors[:success] : t.colors[:text_primary]
          out.primitives << lbl(dx + 10, cy, "#{child.name}  #{status}",
                                color, 16, 0, 1)
        end
      end

      def render_leaf_detail(quest, mgr, t, out, dx, top)
        # Name
        out.primitives << lbl(dx, top - 20, quest.name,
                              t.colors[:accent], 24, 0, 1)

        # Score
        out.primitives << lbl(dx, top - 48, "Score: #{quest.score}",
                              t.colors[:warning], 16, 0, 1)

        # Track/Untrack
        button :detail_track,
          x: dx + 200, y: top - 58,
          w: 100, h: 26,
          text: quest.tracking ? "Untrack" : "Track",
          style: quest.tracking ? :primary : :default,
          size: :sm,
          on_click: ->(b) { mgr.toggle_tracking(quest.id) }

        # Description
        unless quest.description.empty?
          out.primitives << lbl(dx, top - 80, quest.description,
                                t.colors[:text_secondary], 16, 0, 1)
        end

        # Steps
        steps_y = top - 115
        out.primitives << lbl(dx, steps_y, "Steps", t.colors[:text_primary], 20, 0, 1)

        quest.steps.each_with_index do |step, i|
          sy = steps_y - 28 - i * 24
          break if sy < PANEL_Y + 60

          icon = step.complete? ? "[x]" : (step.active ? "[ ]" : "[?]")
          count_text = step.required > 1 ? " (#{step.completions}/#{step.required})" : ""
          color = step.complete? ? t.colors[:success] : (step.active ? t.colors[:text_primary] : t.colors[:text_disabled])

          out.primitives << lbl(dx + 10, sy, "#{icon} #{step.name}#{count_text}",
                                color, 16, 0, 1)
        end

        # Rewards
        if quest.has_rewards?
          ry = steps_y - 28 - quest.steps.length * 24 - 20
          out.primitives << lbl(dx, ry, "Rewards", t.colors[:text_primary], 20, 0, 1)

          quest.rewards.each_with_index do |r, i|
            out.primitives << lbl(dx + 10, ry - 28 - i * 22,
                                  "#{r.name} x#{r.quantity}",
                                  t.colors[:warning], 16, 0, 1)
          end

          if quest.unclaimed_rewards?
            btn_y = ry - 28 - quest.rewards.length * 22 - 10
            button :claim_btn,
              x: dx, y: btn_y,
              w: 140, h: 30,
              text: "Claim Rewards",
              style: :success,
              size: :sm,
              on_click: ->(b) {
                rewards = quest.claim_rewards!
                entity.send_to_scripts(:on_claim_rewards, quest, rewards)
              }
          end
        end

        # Progress bar at bottom
        progress_bar :detail_progress,
          x: dx, y: PANEL_Y + 20,
          w: 400,
          value: quest.progress_percent,
          max: 100,
          label_text: quest.complete? ? "Completed" : "Progress",
          color_key: quest.complete? ? :success : :accent
      end

      # ------------------------------------------------------------------
      # Helpers
      # ------------------------------------------------------------------

      def quest_manager
        return nil unless entity
        qs = entity.respond_to?(:quest_script) ? entity.quest_script : nil
        qs&.manager
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
