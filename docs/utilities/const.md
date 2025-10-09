# Const - Game Constants

The `Hoard::Const` module provides a centralized location for game-wide constants and configuration values. It's designed to make it easy to adjust game parameters in one place.

## Table of Contents

1. [Overview](#overview)
2. [Available Constants](#available-constants)
3. [Methods](#methods)
4. [Usage Examples](#usage-examples)
5. [Best Practices](#best-practices)

## Overview

The `Hoard::Const` module serves as a configuration hub for your game, containing:
- Game grid size definitions
- Scaling factors
- Other global constants

## Available Constants

### `GRID`
- **Type**: Integer
- **Default**: `16`
- **Description**: The base size of a grid cell in pixels. This is used throughout the game for positioning and collision detection.

## Methods

### `self.scale`
Calculates an appropriate scale factor based on the current screen size.

**Returns**:
- Integer: The calculated scale factor

**Implementation**:
```ruby
def self.scale
  Scaler.best_fit_i(300 / 2, 300 / 2)
end
```

## Usage Examples

### Basic Usage

```ruby
# Accessing the grid size
grid_size = ::Game::GRID  # 16

# Using in position calculations
def draw_grid
  (0..$args.grid.w / ::Game::GRID).each do |x|
    (0..$args.grid.h / ::Game::GRID).each do |y|
      # Draw grid cell at (x, y)
      $args.outputs.borders << {
        x: x * ::Game::GRID,
        y: y * ::Game::GRID,
        w: ::Game::GRID,
        h: ::Game::GRID,
        r: 50, g: 50, b: 50
      }
    end
  end
end
```

### Using the Scale Method

```ruby
# Get the current scale factor
scale = Hoard::Const.scale

# Apply scale to UI elements
def render_ui
  button_size = 32 * scale
  $args.outputs.solids << {
    x: 10 * scale,
    y: 10 * scale,
    w: button_size,
    h: button_size,
    r: 255, g: 0, b: 0
  }
end
```

### Extending with Custom Constants

You can extend the `Hoard::Const` module with your own game-specific constants:

```ruby
module Hoard
  class Const
    # Gameplay constants
    GRAVITY = 0.5
    PLAYER_SPEED = 4
    JUMP_FORCE = -12
    
    # UI constants
    UI_PADDING = 8
    FONT_SMALL = 0
    FONT_MEDIUM = 1
    FONT_LARGE = 2
    
    # Animation constants
    ANIMATION_FRAME_DURATION = 4
    
    # Add your own constants here
    # ...
    
    # You can also add class methods
    def self.screen_center_x
      $args.grid.w / 2
    end
    
    def self.screen_center_y
      $args.grid.h / 2
    end
  end
end
```

## Best Practices

1. **Centralized Configuration**:
   - Keep all game-wide constants in this module for easy adjustment
   - Group related constants together with comments

2. **Naming Conventions**:
   - Use UPPER_SNAKE_CASE for constant names
   - Prefix related constants (e.g., `PLAYER_*`, `ENEMY_*`, `UI_*`)

3. **Organization**:
   - Group related constants together
   - Add comments to explain the purpose of each constant
   - Consider using modules to namespace related constants:

     ```ruby
     module Hoard
       class Const
         module Player
           SPEED = 4
           JUMP_FORCE = -12
           MAX_HEALTH = 100
         end
         
         module Enemy
           SPEED = 2
           DAMAGE = 10
         end
       end
     end
     ```

4. **Usage in Code**:
   - Always reference constants through the `Hoard::Const` module
   - Avoid magic numbers in your code - use named constants instead

5. **Performance Considerations**:
   - Constants are initialized when the module is loaded
   - For values that might change during runtime, consider using a configuration class instead

6. **Documentation**:
   - Document the purpose and units of each constant
   - Include expected ranges or valid values

### Example: Complete Game Configuration

Here's an example of a more comprehensive game configuration using the `Const` module:

```ruby
module Hoard
  class Const
    # Grid and rendering
    GRID = 16
    TILE_SIZE = 16
    SCALE = 2
    
    # Physics
    module Physics
      GRAVITY = 0.5
      TERMINAL_VELOCITY = 16
      FRICTION = 0.8
      AIR_RESISTANCE = 0.9
    end
    
    # Player settings
    module Player
      SPEED = 4
      JUMP_FORCE = -10
      CLIMB_SPEED = 3
      DASH_FORCE = 8
      MAX_HEALTH = 100
      INVULNERABILITY_DURATION = 60  # frames
    end
    
    # Enemy settings
    module Enemies
      module Basic
        SPEED = 1.5
        DAMAGE = 10
        HEALTH = 30
        KNOCKBACK = 4
      end
      
      module Flying
        SPEED = 2.0
        DAMAGE = 15
        HEALTH = 20
        KNOCKBACK = 2
      end
    end
    
    # UI settings
    module UI
      PADDING = 8
      MARGIN = 16
      FONT_SMALL = 0
      FONT_MEDIUM = 1
      FONT_LARGE = 2
      
      module Colors
        HEALTH = [255, 50, 50]
        MANA = [50, 100, 255]
        XP = [100, 255, 100]
        TEXT = [255, 255, 255]
        BACKGROUND = [20, 20, 30]
      end
    end
    
    # Animation settings
    module Animation
      FRAME_DURATION = 4
      DAMAGE_FLASH_DURATION = 10
      SCREEN_SHAKE_DURATION = 20
    end
    
    # Game settings
    module Game
      FPS = 60
      DEBUG = true
      SHOW_HITBOXES = false
      SHOW_GRID = false
    end
    
    # Helper methods
    def self.screen_width
      $args.grid.w
    end
    
    def self.screen_height
      $args.grid.h
    end
    
    def self.screen_center
      [screen_width / 2, screen_height / 2]
    end
    
    # Calculate grid-aligned position
    def self.grid_align(x, y)
      [
        (x / GRID).floor * GRID,
        (y / GRID).floor * GRID
      ]
    end
  end
end
```

This documentation covers the core functionality of the `Hoard::Const` module and provides guidance on how to effectively use and extend it for your game's configuration needs.
