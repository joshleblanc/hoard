# Camera System - Screen Effects

The Camera system includes built-in support for dynamic screen effects that can enhance gameplay feedback and visual polish.

## Screen Shake

Add impact and intensity to your game with screen shake effects.

### Basic Shake

```ruby
# Shake the screen for 1 second with normal intensity
@camera.shake_s(1.0)


# Stronger shake (default intensity = 1.0)
@camera.shake_s(0.5, 2.0)  # Shorter duration, higher intensity
```

### Shake Parameters

- `duration`: How long the shake lasts (in seconds)
- `power`: Intensity multiplier (default: 1.0)

### Example: Damage Shake

```ruby
def take_damage(amount)
  @health -= amount
  
  # Shake based on damage taken
  intensity = [amount / @max_health * 2.0, 0.5].max
  @camera.shake_s(0.3, intensity)
  
  # Visual feedback
  flash_damage
end
```

## Camera Bumps

Create quick directional impulses for impacts and explosions.

### Basic Bump

```ruby
# Bump the camera by x, y pixels
@camera.bump(10, -5)  # Bump right and up slightly

# Bump in a direction (angle in radians, distance)
@camera.bump_ang(Math::PI, 20)  # Bump left
```

### Bump Properties

Control how bumps behave:

```ruby
# Adjust bump friction (default: 0.85, higher = less bouncy)
@camera.bump_frict = 0.9

# Get/set current bump offset
current_x = @camera.bump_off_x
current_y = @camera.bump_off_y
```

### Example: Explosion Effect

```ruby
def create_explosion(x, y, power)
  # Create explosion visual
  @game.fx.dots_explosion(x, y, 0xFF6600)
  
  # Bump camera toward explosion
  if @camera.target  # If tracking an entity
    dx = @camera.target.x - x
    dy = @camera.target.y - y
    dist = Math.sqrt(dx*dx + dy*dy)
    
    if dist < 200  # Only if close enough
      # Bump away from explosion
      angle = Math.atan2(dy, dx)
      @camera.bump_ang(angle, power * 5)
      
      # Add screen shake
      @camera.shake_s(0.4, power)
    end
  end
end
```

## Combining Effects

Create more dynamic effects by combining multiple camera movements:

```ruby
def big_impact(x, y)
  # Zoom out quickly then back in
  @camera.zoom_to(0.7)  # Zoom out
  
  # Big screen shake
  @camera.shake_s(1.0, 2.0)
  
  # Bump toward impact point
  if @camera.target
    angle = Math.atan2(y - @camera.target.y, x - @camera.target.x)
    @camera.bump_ang(angle, 30)
  end
  
  # Schedule zoom back in
  Hoard::Scheduler.schedule(30) do |s|
    @camera.zoom_to(1.0)
  end
end
```

## Performance Considerations

1. **Limit Active Effects**: Too many simultaneous effects can be disorienting
2. **Scale with Importance**: Use more intense effects for significant game events
3. **Allow Cooldowns**: Prevent effect stacking that could cause extreme camera movement
4. **Provide Options**: Consider adding settings to reduce or disable screen shake

## Next Steps

- [Advanced Usage](./05_advanced_usage.md)
- [Zoom and Viewport Control](./03_zoom_viewport.md)
- [Entity Tracking](./02_entity_tracking.md)
- [Back to Overview](./01_overview.md)
