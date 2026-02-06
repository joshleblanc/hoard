# ShowcaseWidget -- demonstrates every Hoard::Ui component
#
# This is a single widget that builds the entire showcase UI using
# the DSL methods built into Hoard::Widget: panel, label, button,
# text_input, checkbox, toggle, slider, progress_bar, dropdown,
# radio_group, row, and image.

class ShowcaseWidget < Hoard::Widget
  def init
    @status = "Welcome to the Hoard UI Showcase"
    @counter = 0
    @progress_val = 0
    @typed_text = ""
    @volume = 75
    @speed = 1.0
    @dark_mode = true
    @sound_on = false
    @agree_terms = false
    @remember_me = true
    @difficulty = 1
    @selected_color = -1
  end

  def update
    # Animate the progress bar
    @progress_val = (@progress_val + 0.3) % 101
  end

  def render
    render_title
    render_buttons_section
    render_inputs_section
    render_toggles_section
    render_sliders_section
    render_progress_section
    render_dropdown_section
    render_radio_section
    render_status_bar
  end

  private

  # -------------------------------------------------------------------
  # Title
  # -------------------------------------------------------------------

  def render_title
    label :title,
      x: 640, y: 700,
      text: "Hoard UI Component Showcase",
      size_key: :size_xl,
      color_key: :accent,
      align: :center
  end

  # -------------------------------------------------------------------
  # Buttons (top-left)
  # -------------------------------------------------------------------

  def render_buttons_section
    panel :buttons_panel, x: 20, y: 440, w: 370, h: 230, title: "Buttons" do
      row do
        button :btn_default, text: "Default", w: 105,
               on_click: ->(b) { @status = "Default clicked" }
        button :btn_primary, text: "Primary", w: 105, style: :primary,
               on_click: ->(b) { @status = "Primary clicked" }
        button :btn_ghost, text: "Ghost", w: 105, style: :ghost,
               on_click: ->(b) { @status = "Ghost clicked" }
      end

      row do
        button :btn_success, text: "Success", w: 80, style: :success, size: :sm,
               on_click: ->(b) { @status = "Success!" }
        button :btn_warning, text: "Warning", w: 80, style: :warning, size: :sm,
               on_click: ->(b) { @status = "Warning!" }
        button :btn_danger, text: "Danger", w: 80, style: :danger, size: :sm,
               on_click: ->(b) { @status = "Danger!" }
        button :btn_disabled, text: "Disabled", w: 80, size: :sm, enabled: false
      end

      button :btn_counter, text: "Counter: #{@counter}", style: :primary, size: :lg,
             on_click: ->(b) {
               @counter += 1
               @status = "Counter: #{@counter}"
             }
    end
  end

  # -------------------------------------------------------------------
  # Text Inputs (top-right)
  # -------------------------------------------------------------------

  def render_inputs_section
    panel :inputs_panel, x: 410, y: 440, w: 370, h: 230, title: "Text Inputs" do
      label :name_label, text: "Name", size_key: :size_sm, color_key: :text_secondary
      text_input :name_input,
        placeholder: "Type your name...",
        on_change: ->(inp) { @typed_text = inp.text; @status = "Typing: #{inp.text}" },
        on_submit: ->(inp) { @status = "Submitted: #{inp.text}" }

      label :pass_label, text: "Password", size_key: :size_sm, color_key: :text_secondary
      text_input :pass_input,
        placeholder: "Enter password...",
        password: true,
        max_length: 20

      label :disabled_label, text: "Read-only", size_key: :size_sm, color_key: :text_secondary
      text_input :disabled_input,
        text: "Cannot edit this",
        enabled: false
    end
  end

  # -------------------------------------------------------------------
  # Checkboxes & Toggles (middle-left)
  # -------------------------------------------------------------------

  def render_toggles_section
    panel :toggles_panel, x: 20, y: 175, w: 370, h: 230, title: "Checkboxes & Toggles" do
      checkbox :cb_terms,
        label_text: "I agree to the terms",
        checked: @agree_terms,
        on_change: ->(cb) { @agree_terms = cb.checked; @status = "Terms: #{cb.checked ? 'agreed' : 'declined'}" }

      checkbox :cb_remember,
        label_text: "Remember me",
        checked: @remember_me,
        on_change: ->(cb) { @remember_me = cb.checked; @status = "Remember: #{cb.checked}" }

      checkbox :cb_disabled,
        label_text: "Disabled checkbox",
        enabled: false

      toggle :tgl_dark,
        label_text: "Dark mode",
        on: @dark_mode,
        on_change: ->(t) {
          @dark_mode = t.on
          $hoard_ui_theme = t.on ? Hoard::Ui::Theme.new : Hoard::Ui::Theme.light
          @status = "Theme: #{t.on ? 'Dark' : 'Light'}"
        }

      toggle :tgl_sound,
        label_text: "Sound effects",
        on: @sound_on,
        on_change: ->(t) { @sound_on = t.on; @status = "Sound: #{t.on ? 'ON' : 'OFF'}" }
    end
  end

  # -------------------------------------------------------------------
  # Sliders (middle-right)
  # -------------------------------------------------------------------

  def render_sliders_section
    panel :sliders_panel, x: 410, y: 175, w: 370, h: 230, title: "Sliders" do
      slider :sld_volume,
        label_text: "Volume",
        value: @volume, min: 0, max: 100,
        on_change: ->(s) { @volume = s.value.to_i; @status = "Volume: #{s.value.to_i}" }

      slider :sld_speed,
        label_text: "Speed",
        value: @speed, min: 0.1, max: 3.0, step: 0.1,
        on_change: ->(s) { @speed = s.value; @status = "Speed: #{"%.1f" % s.value}x" }

      slider :sld_disabled,
        label_text: "Locked",
        value: 50, min: 0, max: 100,
        enabled: false
    end
  end

  # -------------------------------------------------------------------
  # Progress Bars (bottom area)
  # -------------------------------------------------------------------

  def render_progress_section
    panel :progress_panel, x: 800, y: 440, w: 460, h: 230, title: "Progress Bars" do
      progress_bar :prog_download,
        value: @progress_val, max: 100,
        label_text: "Download",
        color_key: :accent

      progress_bar :prog_upload,
        value: 75, max: 100,
        label_text: "Upload",
        color_key: :success

      progress_bar :prog_error,
        value: 30, max: 100,
        label_text: "Errors",
        color_key: :error

      progress_bar :prog_warn,
        value: 60, max: 100,
        label_text: "Warnings",
        color_key: :warning
    end
  end

  # -------------------------------------------------------------------
  # Dropdown (bottom-left)
  # -------------------------------------------------------------------

  def render_dropdown_section
    panel :dropdown_panel, x: 800, y: 175, w: 220, h: 230, title: "Dropdown" do
      label :dd_label, text: "Favorite color:", size_key: :size_sm, color_key: :text_secondary

      dropdown :dd_color,
        options: ["Red", "Green", "Blue", "Yellow", "Purple"],
        selected_index: @selected_color,
        placeholder: "Pick a color...",
        on_change: ->(dd) { @selected_color = dd.selected_index; @status = "Color: #{dd.selected_value}" }
    end
  end

  # -------------------------------------------------------------------
  # Radio Group (bottom-right)
  # -------------------------------------------------------------------

  def render_radio_section
    panel :radio_panel, x: 1040, y: 175, w: 220, h: 230, title: "Radio Group" do
      label :diff_label, text: "Difficulty:", size_key: :size_sm, color_key: :text_secondary

      radio_group :rg_difficulty,
        options: ["Easy", "Normal", "Hard", "Nightmare"],
        selected_index: @difficulty,
        on_change: ->(rg) { @difficulty = rg.selected_index; @status = "Difficulty: #{rg.selected_value}" }
    end
  end

  # -------------------------------------------------------------------
  # Status bar (bottom)
  # -------------------------------------------------------------------

  def render_status_bar
    t = $hoard_ui_theme || Hoard::Ui::Theme.new
    bar = t.colors[:bg_surface]
    $args.outputs[:ui].primitives << {
      x: 0, y: 0, w: 1280, h: 34, path: :solid,
      r: bar[:r], g: bar[:g], b: bar[:b]
    }

    status_c = t.colors[:text_secondary]
    $args.outputs[:ui].primitives << {
      x: 10, y: 24, text: @status,
      size_px: 18, anchor_x: 0, anchor_y: 0.5,
      r: status_c[:r], g: status_c[:g], b: status_c[:b]
    }

    fps_c = t.colors[:text_disabled]
    $args.outputs[:ui].primitives << {
      x: 1270, y: 24, text: "#{$args.gtk.current_framerate.to_i} FPS",
      size_px: 16, anchor_x: 1, anchor_y: 0.5,
      r: fps_c[:r], g: fps_c[:g], b: fps_c[:b]
    }

    hint_c = t.colors[:text_disabled]
    $args.outputs[:ui].primitives << {
      x: 640, y: 24, text: "Tab: cycle focus | Click: interact | Toggle dark mode to switch themes",
      size_px: 14, anchor_x: 0.5, anchor_y: 0.5,
      r: hint_c[:r], g: hint_c[:g], b: hint_c[:b]
    }
  end
end
