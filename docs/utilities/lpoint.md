# LPoint - Level Point

The `Hoard::LPoint` class provides a comprehensive solution for handling 2D coordinates in both grid-based and pixel-based coordinate systems. It's particularly useful for games that use tile-based levels but need precise pixel positioning.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Coordinate Systems](#coordinate-systems)
4. [API Reference](#api-reference)
5. [Examples](#examples)
   - [Creating Points](#creating-points)
   - [Converting Between Systems](#converting-between-systems)
   - [Distance and Angles](#distance-and-angles)
6. [Best Practices](#best-practices)

## Overview

`LPoint` (Level Point) provides:
- Dual coordinate representation (grid + pixel)
- Easy conversion between coordinate systems
- Distance and angle calculations
- Screen-to-level coordinate conversion
- Integration with the game's camera system

## Basic Usage

```ruby
# Create a point at grid position (3, 4) with sub-cell offset (0.5, 0.5)
point = Hoard::LPoint.from_case(3, 4)

# Get pixel coordinates
pixel_x = point.level_x  # Returns pixel X based on grid size
pixel_y = point.level_y  # Returns pixel Y based on grid size

# Move to a specific pixel position
point.set_level_pixel(100, 150)


# Convert screen coordinates to level coordinates
screen_point = Hoard::LPoint.from_screen(mouse_x, mouse_y)
```

## Coordinate Systems

### 1. Grid/Cell Coordinates (cx, cy)
- `cx`, `cy`: Integer coordinates representing grid cells
- `xr`, `yr`: Floating-point values [0, 1) representing position within a cell

### 2. Level/Pixel Coordinates
- `level_x`, `level_y`: Exact pixel position in the level
- `level_x_i`, `level_y_i`: Integer pixel position (rounded down)

### 3. Screen Coordinates
- `screen_x`, `screen_y`: Pixel position on screen (accounts for camera)

## API Reference

### Class Methods

#### `LPoint.from_case(cx, cy)`
Creates a point from grid coordinates with optional sub-cell offset.

#### `LPoint.from_case_center(cx, cy)`
Creates a point centered in a grid cell.

#### `LPoint.from_pixel(x, y)`
Creates a point from pixel coordinates.

#### `LPoint.from_screen(sx, sy)`
Creates a point from screen coordinates (accounts for camera).

### Instance Methods

#### Position Setting
- `set_level_case(x, y, xr=0.5, yr=0.5)`: Set position using grid coordinates
- `set_level_pixel(x, y)`: Set position using pixel coordinates
- `set_level_pixel_x(x)`: Set X position using pixel coordinates
- `set_level_pixel_y(y)`: Set Y position using pixel coordinates
- `set_screen(sx, sy)`: Set position using screen coordinates
- `use_point(other)`: Copy position from another LPoint

#### Position Getters
- `cxf`, `cyf`: Full floating-point grid coordinates (cx + xr, cy + yr)
- `level_x`, `level_y`: Pixel coordinates in level space
- `level_x_i`, `level_y_i`: Integer pixel coordinates (floored)
- `screen_x`, `screen_y`: Pixel coordinates in screen space

#### Calculations
- `dist_case(other_or_x, y=0, xr=0.5, yr=0.5)`: Distance in grid units
- `dist_px(other_or_x, y=0)`: Distance in pixels
- `ang_to(other_or_x, y=nil)`: Angle to another point in radians

## Examples

### Creating Points

```ruby
# Different ways to create points
grid_point = Hoard::LPoint.from_case(5, 3)        # Center of cell (5,3)
pixel_point = Hoard::LPoint.from_pixel(100, 150)  # At pixel (100,150)
screen_point = Hoard::LPoint.from_screen(400, 300) # At screen position (400,300)

# Using the constructor
point = Hoard::LPoint.new
point.set_level_case(2, 3, 0.25, 0.75)  # 25% from left, 75% from bottom of cell (2,3)
```

### Converting Between Systems

```ruby
# Create a point at grid (3,4)
point = Hoard::LPoint.from_case(3, 4)

# Convert to pixel coordinates
pixel_x = point.level_x  # e.g., 96 (if GRID=32)
pixel_y = point.level_y  # e.g., 128

# Move to a specific pixel position
point.set_level_pixel(100, 150)


# Get grid position
grid_x = point.cx  # e.g., 3
sub_x = point.xr    # e.g., 0.125 (for 100px with GRID=32)

# Convert screen coordinates to level coordinates
mouse_point = Hoard::LPoint.from_screen(mouse_x, mouse_y)
level_x = mouse_point.level_x
level_y = mouse_point.level_y
```

### Distance and Angles

```ruby
# Distance between two points in grid units
point1 = Hoard::LPoint.from_case(1, 1)
point2 = Hoard::LPoint.from_case(4, 5)
distance = point1.dist_case(point2)  # Grid units

# Distance in pixels
pixel_distance = point1.dist_pixel(point2)

# Angle between points (in radians)
angle = point1.ang_to(point2)

# Convert to degrees if needed
degrees = angle * 180 / Math::PI
```

### Entity Integration

```ruby
class Player < Hoard::Entity
  def initialize
    super
    @position = Hoard::LPoint.new
    @speed = 5
  end
  
  def update
    # Move towards mouse on click
    if $args.inputs.mouse.click
      target = Hoard::LPoint.from_screen(
        $args.inputs.mouse.x, 
        $args.inputs.mouse.y
      )
      
      # Calculate direction
      angle = @position.ang_to(target)
      
      # Move in that direction
      @position.set_level_pixel(
        @position.level_x + Math.cos(angle) * @speed,
        @position.level_y + Math.sin(angle) * @speed
      )
    end
  end
  
  def render
    $args.outputs.sprites << {
      x: @position.screen_x - 16,
      y: @position.screen_y - 16,
      w: 32, h: 32,
      path: 'sprites/player.png'
    }
  end
end
```

## Best Practices

1. **Consistent Usage**: Decide whether to work primarily in grid or pixel coordinates and stick to it.

2. **Performance**: Reuse LPoint instances when possible to avoid object allocation in update loops.

3. **Precision**: Use `cxf`/`cyf` for precise positioning, `cx`/`cy` for grid-based operations.

4. **Camera Awareness**: Remember that `screen_x`/`screen_y` automatically account for camera position.

5. **Grid Size**: Be aware of the `::Game::GRID` value as it affects all grid-to-pixel conversions.

6. **Sub-cell Positioning**: Use `xr`/`yr` for smooth movement within grid cells.

7. **Type Safety**: When working with other systems, be explicit about which coordinate system you're using.

### Common Patterns

#### Movement with Grid Snapping

```ruby
def move_to_grid_position(x, y)
  @position.set_level_case(x, y, 0.5, 0.5)
end

def move_smoothly_to(x, y, speed)
  target = Hoard::LPoint.from_case(x, y, 0.5, 0.5)
  dx = target.level_x - @position.level_x
  dy = target.level_y - @position.level_y
  distance = Math.sqrt(dx*dx + dy*dy)
  
  if distance < speed
    @position.use_point(target)
  else
    @position.set_level_pixel(
      @position.level_x + (dx / distance) * speed,
      @position.level_y + (dy / distance) * speed
    )
  end
end
```

#### Screen-to-Level Coordinate Conversion

```ruby
def handle_click(x, y)
  # Convert screen coordinates to level coordinates
  level_pos = Hoard::LPoint.from_screen(x, y)
  
  # Find the grid cell that was clicked
  grid_x = level_pos.cx
  grid_y = level_pos.cy
  
  # Check if the click was in the upper or lower half of the cell
  if level_pos.yr > 0.5
    puts "Clicked lower half of cell (#{grid_x}, #{grid_y})"
  else
    puts "Clicked upper half of cell (#{grid_x}, #{grid_y})"
  end
end
```

This documentation covers the core functionality of the `Hoard::LPoint` class and provides practical examples of how to use it in your game.
