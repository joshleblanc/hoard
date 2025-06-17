# Scaler System

The `Hoard::Scaler` class provides utility methods for handling screen scaling and aspect ratio calculations in your game. It's particularly useful for creating responsive layouts that work across different screen sizes and resolutions.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [API Reference](#api-reference)
4. [Examples](#examples)
   - [Basic Scaling](#basic-scaling)
   - [Responsive UI](#responsive-ui)
   - [Maintaining Aspect Ratio](#maintaining-aspect-ratio)
5. [Best Practices](#best-practices)

## Overview

The `Hoard::Scaler` class helps you:
- Scale game elements to fit different screen sizes
- Maintain aspect ratios
- Create responsive UI layouts
- Handle both integer and floating-point scaling

## Basic Usage

```ruby
# Get the default viewport dimensions
viewport_w = Hoard::Scaler.viewport_width  # 1280
viewport_h = Hoard::Scaler.viewport_height # 720

# Calculate best fit scale for a 256x256 sprite
scale = Hoard::Scaler.best_fit_f(256, 256)
puts "Best fit scale: #{scale}"

# Calculate integer scale (for pixel-perfect rendering)
int_scale = Hoard::Scaler.best_fit_i(256, 256)
puts "Best integer scale: #{int_scale}"

# Fill the screen while maintaining aspect ratio
fill_scale = Hoard::Scaler.fill_f(1920, 1080)  # For a 16:9 asset
```

## API Reference

### Class Methods

#### `viewport_width`
Returns the default viewport width (1280 pixels).

#### `viewport_height`
Returns the default viewport height (720 pixels).

#### `best_fit_f(width, height = nil, context_width = nil, context_height = nil, allow_below_one = false)`
Calculates the best fit scale factor (as a float) to fit content within a container.

- `width`: Content width in pixels
- `height`: Content height in pixels (defaults to width if nil)
- `context_width`: Container width (defaults to viewport_width)
- `context_height`: Container height (defaults to viewport_height)
- `allow_below_one`: If true, allows scaling below 1.0 (default: false)

Returns the scale factor as a float.

#### `best_fit_i(width, height = nil, context_width = nil, context_height = nil)`
Same as `best_fit_f` but returns an integer (floored) scale factor.

#### `best_fit_aspect_ratio_wid_i(width, aspect_ratio = nil, context_width = nil, context_height = nil)`
Calculates the best fit width while maintaining aspect ratio.

- `width`: Content width in pixels
- `aspect_ratio`: Width/height ratio (defaults to 1.0)
- `context_width`: Container width (defaults to viewport_width)
- `context_height`: Container height (defaults to viewport_height)

#### `fill_f(width, height = nil, context_width = nil, context_height = nil, integer_scale = true)`
Calculates a scale factor that fills the container while maintaining aspect ratio.

- `width`: Content width in pixels
- `height`: Content height in pixels (defaults to width if nil)
- `context_width`: Container width (defaults to viewport_width)
- `context_height`: Container height (defaults to viewport_height)
- `integer_scale`: If true, returns an integer scale factor

## Examples

### Basic Scaling

```ruby
class Game < Hoard::Game
  def initialize
    super
    @sprite = {
      path: 'sprites/character.png',
      w: 64,
      h: 64,
      x: 100,
      y: 100
    }
    
    # Calculate scale for a 64x64 sprite to fit in a 128x128 box
    @scale = Hoard::Scaler.best_fit_f(64, 64, 128, 128)
  end
  
  def render
    # Apply the scale
    $args.outputs.sprites << @sprite.merge(
      x: @sprite[:x],
      y: @sprite[:y],
      w: @sprite[:w] * @scale,
      h: @sprite[:h] * @scale
    )
  end
end
```

### Responsive UI

```ruby
class UIManager
  def initialize
    # Define UI elements with their base dimensions (for 1280x720)
    @elements = [
      { x: 50, y: 50, w: 200, h: 100, color: 0xff0000ff },
      { x: 300, y: 50, w: 200, h: 100, color: 0x00ff00ff },
      { x: 550, y: 50, w: 200, h: 100, color: 0x0000ffff }
    ]
    
    # Calculate scale factor for current resolution
    @scale = Hoard::Scaler.best_fit_f(1280, 720, $args.grid.w, $args.grid.h)
  end
  
  def render
    # Scale and position UI elements
    @elements.each do |element|
      $args.outputs.solids << {
        x: element[:x] * @scale,
        y: element[:y] * @scale,
        w: element[:w] * @scale,
        h: element[:h] * @scale,
        a: 128
      }.merge(element)
    end
  end
end
```

### Maintaining Aspect Ratio

```ruby
class Game < Hoard::Game
  def initialize
    super
    # For a 16:9 game that should maintain aspect ratio
    @game_width = 1280
    @game_height = 720
    
    # Calculate scale and letterbox/pillarbox
    @scale = Hoard::Scaler.best_fit_f(@game_width, @game_height, $args.grid.w, $args.grid.h)
    
    # Calculate viewport offset for letterboxing
    @offset_x = ($args.grid.w - (@game_width * @scale)) / 2
    @offset_y = ($args.grid.h - (@game_height * @scale)) / 2
  end
  
  def render
    # Render game content with scaling and centering
    $args.outputs.sprites << {
      x: @offset_x,
      y: @offset_y,
      w: @game_width * @scale,
      h: @game_height * @scale,
      path: :pixel,
      r: 0, g: 0, b: 0
    }
    
    # Render your game sprites with the same transformation
    render_game_objects(@offset_x, @offset_y, @scale)
    
    # Render UI on top (not scaled)
    render_ui
  end
  
  def render_game_objects(offset_x, offset_y, scale)
    # Example: render a sprite with scaling
    $args.outputs.sprites << {
      x: offset_x + (100 * scale),
      y: offset_y + (100 * scale),
      w: 64 * scale,
      h: 64 * scale,
      path: 'sprites/character.png'
    }
  end
end
```

## Best Practices

1. **Use Consistent Coordinate System**: Decide whether to work in "game coordinates" or "screen coordinates" and stick to it.

2. **Scale Once, If Possible**: Calculate scales at initialization or when the window is resized, not every frame.

3. **Handle Different Aspect Ratios**: Be prepared for various screen shapes by testing different aspect ratios.

4. **Pixel-Perfect Scaling**: Use `best_fit_i` for pixel art to avoid blurry sprites.

5. **UI Scaling**: Consider using a separate scaling factor for UI elements to ensure readability.

6. **Performance**: For performance-critical code, cache scale calculations instead of recalculating them.

7. **Testing**: Test your game at different resolutions and aspect ratios to ensure proper scaling.

### Common Pitfalls

1. **Aspect Ratio Distortion**: Forgetting to maintain aspect ratio when scaling can make your game look stretched.

2. **Off-by-One Errors**: Be careful with integer scaling to avoid gaps or overlaps in tiled backgrounds.

3. **Touch Controls**: If your game has touch controls, remember to scale the touch input coordinates to match your game's coordinate system.

4. **Font Sizes**: Text may need special handling to remain readable at different scales.

5. **Performance Issues**: Excessive scaling of large textures can impact performance on lower-end devices.

This documentation covers the core functionality of the `Hoard::Scaler` class and provides practical examples of how to use it in your game.
