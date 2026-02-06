module Hoard
  class Widget
    attr_gtk

    attr_accessor :entity, :visible, :init_once_done, :z_index, :z_order

    attr :offset_x, :offset_y
    attr_reader :uuid

    PADDING = 18
    @@_z_counter = 0

    def initialize
      @visible = true
      @offset_x = 0
      @offset_y = 0
      @uuid = $gtk.create_uuid
      @z_index = 0   # Fixed layer. Set manually. Higher = always on top.
      @z_order = 0   # Dynamic order within a layer. Bumped by show!.

      # New UI system
      @_ui_ctx = nil
      @_ui_registry = {}
      @_ui_layout_stack = []
      @_ui_layout_cursors = {}
      @_ui_current_direction = nil
      @_ui_row_x = 0
      @_ui_row_spacing = 8
    end

    # ------------------------------------------------------------------
    # Lifecycle (called by Widgetable#send_to_widgets)
    # ------------------------------------------------------------------

    def pre_update; end

    def update; end

    def post_update
      if visible?
        # Reset layout state for this frame
        @_ui_layout_cursors = {}
        @_ui_layout_stack = []
        @_ui_current_direction = nil

        render

        # Tick and push UI primitives to the :ui render target
        _ui_context.render($args)
      end
    end

    def render; end

    # ------------------------------------------------------------------
    # UI Context
    # ------------------------------------------------------------------

    def _ui_context
      @_ui_ctx ||= Ui::Context.new(
        theme: $hoard_ui_theme || Ui::Theme.new,
        render_target: :ui
      )
    end

    def ui_theme
      _ui_context.theme
    end

    # ------------------------------------------------------------------
    # Component DSL - these are the methods widget authors use in render
    # ------------------------------------------------------------------

    def button(id, **opts)
      _upsert(id, Ui::Button, **opts)
    end

    def label(id, **opts)
      _upsert(id, Ui::Label, **opts)
    end

    def text_input(id, **opts)
      _upsert(id, Ui::TextInput, **opts)
    end

    def checkbox(id, **opts)
      _upsert(id, Ui::Checkbox, **opts)
    end

    def toggle(id, **opts)
      _upsert(id, Ui::Toggle, **opts)
    end

    def slider(id, **opts)
      _upsert(id, Ui::Slider, **opts)
    end

    def progress_bar(id, **opts)
      _upsert(id, Ui::ProgressBar, **opts)
    end

    def dropdown(id, **opts)
      _upsert(id, Ui::Dropdown, **opts)
    end

    def radio_group(id, **opts)
      _upsert(id, Ui::RadioGroup, **opts)
    end

    # Panel with auto-layout block. Components inside the block are
    # stacked vertically within the panel's content area.
    def panel(id, **opts, &blk)
      p = _upsert(id, Ui::Panel, **opts)

      if blk
        @_ui_layout_stack.push(p)
        @_ui_layout_cursors[id] ||= { y: 0, index: 0 }
        @_ui_layout_cursors[id][:y] = 0
        @_ui_layout_cursors[id][:index] = 0

        instance_eval(&blk)

        @_ui_layout_stack.pop
      end

      p
    end

    # Horizontal grouping inside a panel block.
    # After the row, the vertical cursor advances by the row height.
    def row(spacing: 8, height: 40, &blk)
      return unless blk

      parent = @_ui_layout_stack.last
      return instance_eval(&blk) unless parent

      old_direction = @_ui_current_direction
      @_ui_current_direction = :horizontal
      @_ui_row_x = 0
      @_ui_row_spacing = spacing

      instance_eval(&blk)

      @_ui_current_direction = old_direction

      # Advance the vertical cursor past this row
      cursor = @_ui_layout_cursors[parent.id]
      if cursor
        cursor[:y] += height + 6
      end
    end

    # Render a raw sprite into the :ui render target (for sprite-sheet HUDs etc.)
    def image(**opts)
      $args.outputs[:ui].sprites << opts
    end

    # ------------------------------------------------------------------
    # Entity-relative positioning helpers
    # ------------------------------------------------------------------

    def entity_x(offset = 0)
      return 0 unless entity
      (entity.respond_to?(:gx) ? entity.gx : entity.x) + offset
    end

    def entity_y(offset = 0)
      return 0 unless entity
      (entity.respond_to?(:gy) ? entity.gy : entity.y) + offset
    end

    # ------------------------------------------------------------------
    # Component lookup / removal
    # ------------------------------------------------------------------

    def find_component(id)
      @_ui_registry[id]
    end

    def remove_component(id)
      comp = @_ui_registry.delete(id)
      _ui_context.remove(comp) if comp
    end

    def clear_components
      @_ui_registry.each_value { |c| _ui_context.remove(c) }
      @_ui_registry.clear
    end

    # ------------------------------------------------------------------
    # Coordinate helpers (kept from original Widget)
    # ------------------------------------------------------------------

    def screen_x(from)
      Hoard.config.game_class.s.camera.level_to_global_x(from)
    end

    def screen_y(from)
      Hoard.config.game_class.s.camera.level_to_global_y(from)
    end

    def screen_w(from)
      from / Hoard.config.game_class::SCALE
    end

    def grid_x(from)
      screen_x(from) / (1280 / 24)
    end

    def grid_y(from)
      (screen_y(from) / (720 / 12))
    end

    # ------------------------------------------------------------------
    # Visibility
    # ------------------------------------------------------------------

    def visible?
      visible
    end

    def show!
      @visible = true
      @@_z_counter += 1
      @z_order = @@_z_counter
    end

    def hide!
      @visible = false
    end

    def toggle!
      if @visible
        hide!
      else
        show!
      end
    end

    # ------------------------------------------------------------------
    # Serialization
    # ------------------------------------------------------------------

    def to_h
      {}.tap do |klass|
        instance_variables.reject { |v|
          v == :@entity || v == :@args ||
          v.to_s.start_with?("@_ui")
        }.each do |k|
          klass[k.to_s[1..-1].to_sym] = instance_variable_get(k)
        end
      end
    end

    def serialize
      to_h
    end

    def to_s
      serialize.to_s
    end

    # ------------------------------------------------------------------
    # Entity lifecycle hooks (empty defaults)
    # ------------------------------------------------------------------

    def on_pre_step_x; end
    def on_pre_step_y; end
    def init; end
    def on_collision(entity); end

    private

    # ------------------------------------------------------------------
    # Core upsert: create-or-update a component by id
    # ------------------------------------------------------------------

    def _upsert(id, klass, **opts)
      _resolve_layout_position!(id, opts)

      existing = @_ui_registry[id]

      if existing
        _update_component(existing, opts)
        existing
      else
        comp = klass.new(id: id, **opts)
        @_ui_registry[id] = comp
        _ui_context.add(comp)

        parent_panel = @_ui_layout_stack.last
        parent_panel.add(comp) if parent_panel.is_a?(Ui::Panel)

        comp
      end
    end

    def _update_component(comp, opts)
      opts.each do |key, val|
        setter = "#{key}="
        comp.send(setter, val) if comp.respond_to?(setter)
      end
    end

    # Auto-position components inside panels
    def _resolve_layout_position!(id, opts)
      parent = @_ui_layout_stack.last
      return unless parent.is_a?(Ui::Panel)

      cr = parent.content_rect
      parent_id = parent.id
      cursor = @_ui_layout_cursors[parent_id]
      return unless cursor

      spacing = 6

      opts[:w] ||= cr[:w]

      existing = @_ui_registry[id]
      comp_h = opts[:h] || (existing ? existing.h : 30)

      if @_ui_current_direction == :horizontal
        opts[:x] ||= cr[:x] + @_ui_row_x
        opts[:y] ||= cr[:y] + cr[:h] - cursor[:y] - comp_h
        @_ui_row_x += (opts[:w] || 100) + @_ui_row_spacing
      else
        opts[:x] ||= cr[:x]
        opts[:y] ||= cr[:y] + cr[:h] - cursor[:y] - comp_h
        cursor[:y] += comp_h + spacing
      end

      cursor[:index] += 1
    end
  end
end
