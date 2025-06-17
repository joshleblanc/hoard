# Camera System - Entity Tracking

## Following Game Objects

The camera can track any game object that provides `center_x` and `center_y` methods. This works seamlessly with Hoard's `Entity` class.

### Basic Tracking

```ruby
# Start tracking an entity
@camera.track_entity(player_entity, immediate: false, speed: 1.0)

# Stop tracking
@camera.stop_tracking

# Center immediately on target (ignores smoothing)
@camera.center_on_target
```

### Tracking Parameters

- `entity`: The target entity to follow (must respond to `center_x` and `center_y`)
- `immediate`: If `true`, snaps to target immediately
- `speed`: Tracking speed (higher = faster, lower = smoother)

### Target Offsets

Offset the camera from the tracked entity:

```ruby
# Set fixed offset
@camera.target_off_x = 50  # 50 pixels right
@camera.target_off_y = -30 # 30 pixels up

# Dynamic offset (e.g., for looking ahead)
@camera.target_off_x = player.facing_right? ? 100 : -100
```

### Dead Zones

Control when the camera starts following:

```ruby
# Set dead zone as percentage of screen size (default: 4% X, 10% Y)
@camera.dead_zone_pct_x = 0.1  # 10% of screen width
@camera.dead_zone_pct_y = 0.15  # 15% of screen height
```

### Example: Player Camera

```ruby
class Player < Hoard::Entity
  def initialize
    super
    # ... player setup ...
  end
  
  def update
    super
    
    # Update camera offset based on input
    if input.right
      @camera.target_off_x = 100  # Look right
    elsif input.left
      @camera.target_off_x = -100 # Look left
    else
      @camera.target_off_x = 0    # Center
    end
  end
end

# In game setup
@player = Player.new
@camera.track_entity(@player, false, 0.8)  # Smooth follow
```

### Advanced: Custom Tracking Logic

For more control, you can manually update the camera position:

```ruby
def update
  # Calculate desired position
  target_x = calculate_camera_x
  target_y = calculate_camera_y
  
  # Apply with smoothing
  @camera.raw_focus.level_x += (target_x - @camera.raw_focus.level_x) * 0.1
  @camera.raw_focus.level_y += (target_y - @camera.raw_focus.level_y) * 0.1
  
  super
end
```

## Next Steps

- [Zoom and Viewport Control](./03_zoom_viewport.md)
- [Screen Effects](./04_screen_effects.md)
- [Advanced Usage](./05_advanced_usage.md)
- [Back to Overview](./01_overview.md)
