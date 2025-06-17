# Layer System

The `Hoard::Layer` class provides a simple way to manage and render background layers in your game, such as parallax backgrounds or static backdrops.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [API Reference](#api-reference)
4. [Examples](#examples)
   - [Creating a Background Layer](#creating-a-background-layer)
   - [Parallax Scrolling](#parallax-scrolling)
   - [Layer Stack](#layer-stack)
5. [Best Practices](#best-practices)

## Overview

The `Hoard::Layer` class is a sprite-based component that can be used to create:
- Static background images
- Parallax scrolling layers
- Fullscreen overlays
- Scaled and positioned visual elements

It's particularly useful for creating depth in your game through parallax scrolling effects, where different layers move at different speeds to simulate depth.

## Basic Usage

```ruby
# Create a new layer with an image path
@background = Hoard::Layer.new("sprites/backgrounds/forest.png")

# Set initial position and size
@background.x = 0
@background.y = 0
@background.w = 1280  # Width of the game viewport
@background.h = 720   # Height of the game viewport

# Set scale (1.0 = 100%)
@background.scale = 1.5  # Scales uniformly
# or
@background.scale_x = 1.2
@background.scale_y = 1.0

# In your render method
def render
  @background.render_components
  # ... render other game objects ...
end
```

## API Reference

### Initialization

```ruby
# Create a new layer with an image path
layer = Hoard::Layer.new("path/to/image.png")
```

### Properties

- `x`, `y`: Position of the layer (default: 0, 0)
- `w`, `h`: Dimensions of the layer (default: 1280x720)
- `scale_x`, `scale_y`: Scale factors for the layer (default: 1.0, 1.0)
- `path`: Path to the image file
- `original_width`, `original_height`: Original dimensions of the layer

### Methods

- `scale=(value)`: Set both scale_x and scale_y to the same value
- `draw_override(ffi_draw)`: Low-level rendering method used by DragonRuby
- `serialize`: Returns a hash representation of the layer's state
- `inspect` and `to_s`: String representations for debugging

## Examples

### Creating a Background Layer

```ruby
class Game < Hoard::Game
  def initialize
    super
    
    # Create a background layer
    @background = Hoard::Layer.new("sprites/backgrounds/forest.png")
    @background.x = 0
    @background.y = 0
    @background.w = 1280
    @background.h = 720
    
    # Create a foreground layer
    @foreground = Hoard::Layer.new("sprites/backgrounds/forest_foreground.png")
    @foreground.x = 0
    @foreground.y = 0
    @foreground.w = 1280
    @foreground.h = 720
  end
  
  def render
    # Render background first
    $args.outputs.sprites << @background
    
    # Render game objects here
    render_entities
    
    # Render foreground on top
    $args.outputs.sprites << @foreground
    
    # Render UI on top of everything
    render_ui
  end
end
```

### Parallax Scrolling

```ruby
class ParallaxBackground
  def initialize
    # Create multiple layers with different scales
    @layers = [
      create_layer("sprites/parallax/sky.png", 0.2),
      create_layer("sprites/parallax/mountains.png", 0.4),
      create_layer("sprites/parallax/trees.png", 0.7),
      create_layer("sprites/parallax/ground.png", 1.0)
    ]
    
    @camera_x = 0
    @camera_y = 0
  end
  
  def create_layer(path, parallax_factor)
    layer = Hoard::Layer.new(path)
    layer.x = 0
    layer.y = 0
    layer.w = 1280
    layer.h = 720
    layer.scale = 1.0 + (1.0 - parallax_factor) * 0.5  # Scale based on parallax
    layer.define_singleton_method(:parallax_factor) { parallax_factor }
    layer
  end
  
  def update(camera_x, camera_y)
    @camera_x = camera_x
    @camera_y = camera_y
  end
  
  def render
    @layers.each do |layer|
      # Apply parallax effect based on camera position
      layer.x = -@camera_x * layer.parallax_factor
      layer.y = -@camera_y * layer.parallax_factor
      
      # Render the layer
      $args.outputs.sprites << layer
    end
  end
end

# In your game:
@parallax = ParallaxBackground.new

def tick
  # Update parallax with camera position
  @parallax.update(@camera.x, @camera.y)
  
  # Render the parallax background
  @parallax.render
end
```

## Best Practices

1. **Layer Order**: Add layers in back-to-front order (background first, foreground last)
2. **Performance**: Use appropriately sized textures to balance quality and performance
3. **Parallax**: Use different parallax factors for depth (lower values = further away)
4. **Memory Management**: Reuse layer instances when possible
5. **Texture Atlases**: For many layers, consider using texture atlases to reduce draw calls
6. **Scaling**: Be mindful of how scaling affects performance and visual quality
7. **Serialization**: Use the `serialize` method for saving/loading layer states

### Performance Considerations

- **Texture Size**: Larger textures consume more memory and can impact performance
- **Draw Calls**: Each layer requires a separate draw call, so minimize the number of layers
- **Off-screen Culling**: Only render layers that are visible in the current viewport
- **Texture Formats**: Use compressed texture formats when possible to reduce memory usage

### Common Pitfalls

1. **Memory Leaks**: Always clean up unused layers
2. **Z-fighting**: Be careful with overlapping layers that have similar parallax factors
3. **Performance Issues**: Too many layers or large textures can cause frame rate drops
4. **Coordinate Systems**: Remember that layer positions are relative to the viewport

This documentation covers the core functionality of the `Hoard::Layer` class and provides practical examples of how to use it in your game.
