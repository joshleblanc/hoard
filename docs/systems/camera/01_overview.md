# Camera System - Overview

The Camera system in Hoard provides powerful viewport control, enabling smooth following, zooming, and screen effects. It's built on top of the `Process` system and integrates with DragonRuby's rendering pipeline.

## Key Features

- **Entity Tracking**: Follow game objects smoothly with configurable behavior
- **Zoom Control**: Dynamic zooming with easing and bounds checking
- **Screen Effects**: Built-in screen shake and bump effects
- **Viewport Management**: Handle screen coordinates and level boundaries
- **Performance Optimized**: Efficient updates and rendering

## Basic Concepts

### Coordinate Systems

1. **World Coordinates**: The game world's coordinate system
2. **Screen Coordinates**: The rendered viewport coordinates
3. **Camera Space**: The transformed space after camera application

### Core Components

- `Camera`: Main class handling viewport transformations
- `LPoint`: Lightweight 2D point class used for camera positioning
- `Scaler`: Handles screen scaling and resolution independence

## Basic Setup

```ruby
# In your game class
def initialize
  super
  
  # Create and configure camera
  @camera = Hoard::Camera.new
  
  # Add to game's process list
  @camera.add_to_game(self)
  
  # Set initial zoom
  @camera.zoom_to(1.0)
end

def tick
  # Apply camera transformations
  @camera.apply
  
  # Your rendering code here
  # ...
  
  super # Process updates (including camera)
end
```

## Next Steps

- [Entity Tracking](./02_entity_tracking.md)
- [Zoom and Viewport Control](./03_zoom_viewport.md)
- [Screen Effects](./04_screen_effects.md)
- [Advanced Usage](./05_advanced_usage.md)
