class HealthWidget < Hoard::Widget
  FULL = {
    path: "samples/platformer/sprites/spritesheet-tiles-default.png",
    w: 48, h: 48,
    tile_w: 64, tile_h: 64,
    tile_x: 13 * 64, tile_y: 0
  }

  HALF = {
    path: "samples/platformer/sprites/spritesheet-tiles-default.png",
    w: 48, h: 48,
    tile_w: 64, tile_h: 64,
    tile_x: 12 * 64, tile_y: 16 * 64
  }

  EMPTY = {
    path: "samples/platformer/sprites/spritesheet-tiles-default.png",
    w: 48, h: 48,
    tile_w: 64, tile_h: 64,
    tile_x: 12 * 64, tile_y: 17 * 64
  }

  def init
    @ui_root = nil
  end

  def render
    # Create UI
    @ui_root = create_ui

    # Update and render
    @ui_root.layout
    @ui_root.update(args)
    @ui_root.render(args)
  end

  def create_ui
    health_script = entity.health_script
    max_health = health_script.life.max
    current_health = health_script.life.v

    # Calculate how many hearts we'll show
    heart_count = (max_health / 2.0).ceil
    # Calculate total width: hearts + gaps + padding
    # Each heart is 48px, gap is -8px between hearts
    content_width = (heart_count * 48) + ((heart_count - 1) * -8) + (8 * 2)

    Hoard::UI::Box.new(
      key: :health_display,
      x: 1280 - content_width - 32,  # Position so right edge is at screen - 32
      y: 720 - 32,
      direction: :horizontal,
      gap: -8,  # Slight overlap for hearts
      padding: 8,
      background: [0, 0, 0, 100],
      border: true,
      border_color: [255, 255, 255, 100],
      widget: self  # IMPORTANT: Pass widget reference
    ) do
      # Render hearts based on max health
      # Each heart represents 2 health points
      heart_count = (max_health / 2.0).ceil

      heart_count.times do |i|
        # Calculate which sprite to show for this heart
        heart_index = i * 2  # Each heart represents positions 0-1, 2-3, 4-5, etc.

        sprite_config = if current_health > heart_index + 1
          # Full heart (both halves filled)
          FULL
        elsif current_health == heart_index + 1
          # Half heart (one half filled)
          HALF
        else
          # Empty heart
          EMPTY
        end

        image(
          key: "heart_#{i}",
          **sprite_config
        )
      end
    end
  end

  def post_update
    super
    # No need to recreate - render will handle it
  end
end
