# Camera System - Zoom and Viewport

## Zoom Control

The camera provides smooth zooming with configurable bounds and easing.

### Basic Zooming

```ruby
# Zoom to a specific level (1.0 = 100%)
@camera.zoom_to(1.5)  # Zoom in to 150%

# Force immediate zoom (no animation)
@camera.force_zoom(0.8)  # Zoom out to 80% immediately

# Get current zoom level
current_zoom = @camera.zoom
```

### Zoom Bounds

Set minimum and maximum zoom levels:

```ruby
# Set zoom constraints
@camera.MIN_ZOOM = 0.5  # Can't zoom out past 50%
@camera.MAX_ZOOM = 2.0  # Can't zoom in past 200%
```

### Zoom Speed and Easing

Control how quickly the camera zooms:

```ruby
# Adjust zoom speed (default: 0.0014)
@camera.zoom_speed = 0.002

# Adjust zoom friction (default: 0.9)
@camera.zoom_frict = 0.95  # Smoother zooming
```

### Viewport Management

Get information about the current viewport:

```ruby
# Get viewport dimensions in world units
width = @camera.px_wid   # Viewport width
height = @camera.px_hei  # Viewport height

# Get viewport bounds in world coordinates
left = @camera.px_left
right = @camera.px_right
top = @camera.px_top
bottom = @camera.px_bottom

# Check if a point is in view
if @camera.on_screen?(x, y)
  # Point is visible
end

# Check if a rectangle is in view
if @camera.on_screen_rect?(x, y, width, height)
  # Rectangle is at least partially visible
end
```

### Level Bounds

Constrain the camera to stay within level boundaries:

```ruby
# Enable/disable bounds clamping (default: false)
@camera.clamp_to_level_bounds = true

# Set how quickly the camera slows down near bounds (0.0-1.0)
@camera.brake_dist_near_bounds = 0.2

# In your level setup:
@level_width = 100 * Const::GRID  # 100 tiles wide
@level_height = 30 * Const::GRID  # 30 tiles tall

def update
  # Update camera bounds based on level size
  @camera.set_level_bounds(0, 0, @level_width, @level_height)
  
  super
end
```

### Example: Zoom to Fit

```ruby
def zoom_to_fit(entities)
  return if entities.empty?
  
  # Find bounds of all entities
  min_x = entities.min_by(&:x).x
  max_x = entities.max_by { |e| e.x + e.w }.x + e.w
  min_y = entities.min_by(&:y).y
  max_y = entities.max_by { |e| e.y + e.h }.y + e.h
  
  # Add padding
  padding = 100
  width = (max_x - min_x) + padding * 2
  height = (max_y - min_y) + padding * 2
  
  # Calculate required zoom to fit
  view_ratio = @camera.px_wid.to_f / @camera.px_hei
  bounds_ratio = width.to_f / height
  
  if bounds_ratio > view_ratio
    # Constrained by width
    zoom = (@camera.px_wid / width) * 0.9  # 90% of available space
  else
    # Constrained by height
    zoom = (@camera.px_hei / height) * 0.9
  end
  
  # Apply zoom with constraints
  @camera.zoom_to([@camera.MIN_ZOOM, [zoom, @camera.MAX_ZOOM].min].max)
  
  # Center on the bounds
  @camera.raw_focus.level_x = min_x + (max_x - min_x) / 2
  @camera.raw_focus.level_y = min_y + (max_y - min_y) / 2
  @camera.clamped_focus.copy_from(@camera.raw_focus)
end
```

## Next Steps

- [Screen Effects](./04_screen_effects.md)
- [Advanced Usage](./05_advanced_usage.md)
- [Entity Tracking](./02_entity_tracking.md)
- [Back to Overview](./01_overview.md)
