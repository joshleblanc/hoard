class CoinsWidget < Hoard::Widget
attr_accessor :coins

  def init
    @coins = 0
    @ui_root = nil
  end

  def render
    # Create UI if it doesn't exist or recreate it
    @ui_root = create_ui

    # Update and render
    @ui_root.layout
    @ui_root.update(args)
    @ui_root.render(args)
  end

  def create_ui
    Hoard::UI::Box.new(
      key: :coins_display,
      x: 32,
      y: 720 - 32,  # Top of screen minus offset
      direction: :horizontal,
      gap: 8,
      padding: 8,
      background: [0, 0, 0, 100],
      border: true,
      border_color: [255, 255, 255, 100],
      widget: self  # IMPORTANT: Pass widget reference for method_missing
    ) do
      # Coin icon
      image(
        key: :coin_icon,
        path: "samples/platformer/sprites/spritesheet-tiles-default.png",
        w: 48,
        h: 48,
        tile_w: 64,
        tile_h: 64,
        tile_x: 13 * 64,
        tile_y: 1 * 64
      )

      # Coin count - display each digit as an image
      box(
        key: :coin_count,
        direction: :horizontal,
        gap: -10  # Negative gap for overlapping digits
      ) do
        # Access coins via method_missing (resolves to @coins on widget)
        coin_value = coins || 0

        if coin_value == 0
          # Show single 0 digit
          image(
            key: "digit_0",
            path: "samples/platformer/sprites/spritesheet-tiles-default.png",
            w: 48,
            h: 48,
            tile_w: 64,
            tile_h: 64,
            tile_x: 13 * 64,
            tile_y: 13 * 64  # Digit 0
          )
        else
          # Show each digit
          coin_value.to_s.each_char.with_index do |char, i|
            digit = char.to_i
            image(
              key: "digit_#{i}",
              path: "samples/platformer/sprites/spritesheet-tiles-default.png",
              w: 48,
              h: 48,
              tile_w: 64,
              tile_h: 64,
              tile_x: 13 * 64,
              tile_y: (13 - digit) * 64
            )
          end
        end
      end
    end
  end

  def post_update
    super
    # No need to recreate - render will handle it
  end
end
