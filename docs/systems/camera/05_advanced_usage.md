# Camera System - Advanced Usage

## Custom Camera Behaviors

Create sophisticated camera movements by extending the base Camera class.

### Creating a Custom Camera

```ruby
class GameCamera < Hoard::Camera
  def initialize
    super
    @custom_offset_x = 0
    @custom_offset_y = 0
    @smooth_speed = 0.1
  end
  
  def update
    # Add custom behavior before standard update
    update_custom_offset
    
    # Call parent update
    super
  end
  
  def apply
    # Store original offsets
    orig_x = @target_off_x
    orig_y = @target_off_y
    
    # Apply custom offsets
    @target_off_x += @custom_offset_x
    @target_off_y += @custom_offset_y
    
    # Apply standard camera transform
    super
    
    # Restore original offsets
    @target_off_x = orig_x
    @target_off_y = orig_y
  end
  
  private
  
  def update_custom_offset
    # Example: Move camera based on player velocity
    if @target&.respond_to?(:vx) && @target&.respond_to?(:vy)
      # Smoothly interpolate toward target offset
      target_x = @target.vx * 10  # Scale factor
      target_y = @target.vy * 5
      
      @custom_offset_x += (target_x - @custom_offset_x) * @smooth_speed
      @custom_offset_y += (target_y - @custom_offset_y) * @smooth_speed
    end
  end
end
```

## Cutscene System

Create cinematic sequences with the camera:

```ruby
def play_cutscene
  # Store original camera state
  original_target = @camera.target
  original_zoom = @camera.zoom
  
  # Start cutscene
  @camera.stop_tracking
  
  # Move to first position
  move_camera_to(hero.x, hero.y, 1.5)
  
  # Zoom in on hero
  @camera.zoom_to(1.8)
  
  # Wait for movement to complete
  Hoard::Scheduler.schedule(90) do |s|
    # Show dialogue
    show_dialogue("Behold! The ancient temple!")
    
    # Move to show temple
    s.wait(60) do
      move_camera_to(temple.x, temple.y, 2.0)
      @camera.zoom_to(1.2)
    end
    
    # Return to player
    s.wait(120) do
      @camera.track_entity(hero)
      @camera.zoom_to(original_zoom)
    end
  end
end

def move_camera_to(x, y, duration_seconds)
  start_x = @camera.raw_focus.level_x
  start_y = @camera.raw_focus.level_y
  
  duration_frames = (duration_seconds * 60).to_i
  
  Hoard::Scheduler.schedule do |s|
    s.wait(duration_frames) do |t|
      # Calculate progress (0.0 to 1.0)
      progress = t.to_f / duration_frames
      
      # Apply easing (ease in-out)
      progress = ease_in_out_quad(progress)
      
      # Update camera position
      @camera.raw_focus.level_x = start_x + (x - start_x) * progress
      @camera.raw_focus.level_y = start_y + (y - start_y) * progress
      
      # Stop when complete
      if progress >= 1.0
        @camera.raw_focus.level_x = x
        @camera.raw_focus.level_y = y
        :stop  # Stop this scheduled task
      end
    end
  end
end

def ease_in_out_quad(x)
  x < 0.5 ? 2 * x * x : 1 - (-2 * x + 2) ** 2 / 2
end
```

## Performance Optimization

### Culling Invisible Objects

```ruby
# In your render method
def render_entities(entities)
  entities.each do |entity|
    # Skip rendering if entity is off-screen
    next unless @camera.on_screen_rect?(
      entity.x, entity.y, entity.w, entity.h, 100 # 100px padding
    )
    
    # Render the entity
    entity.render
  end
end
```

### Level of Detail (LOD)

```ruby
def render_entity(entity)
  # Calculate distance from camera
  dx = entity.x - @camera.raw_focus.level_x
  dy = entity.y - @camera.raw_focus.level_y
  distance = Math.sqrt(dx*dx + dy*dy)
  
  # Choose appropriate LOD based on distance and zoom
  if distance > 500 / @camera.zoom
    # Far away - use simple representation
    entity.render_simple
  else
    # Close up - use detailed representation
    entity.render_detailed
  end
end
```

## Troubleshooting

### Camera Jitter

```ruby
# In your game's update method
def update
  # Update camera first
  @camera.update
  
  # Then update entities with the latest camera position
  update_entities
  
  # Apply camera transforms for rendering
  @camera.apply
  
  super
end
```

### Smooth Following Issues

```ruby
# For smoother following, adjust these properties:
@camera.base_frict = 0.93     # Default: 0.89 (higher = smoother)
@camera.tracking_speed = 1.2  # Default: 1.0 (higher = faster follow)

# Reduce dead zone for more responsive controls
@camera.dead_zone_pct_x = 0.06  # Default: 0.04
@camera.dead_zone_pct_y = 0.12  # Default: 0.10
```

## Complete Example: Platformer Camera

```ruby
class PlatformerCamera < Hoard::Camera
  def initialize
    super
    # Platformer-specific settings
    @look_ahead = 100
    @look_ahead_speed = 0.1
    @current_look = 0
    @min_height = 180  # Minimum viewport height in pixels
  end
  
  def update
    if @target
      # Calculate look ahead based on input
      target_look = @target.facing_right? ? @look_ahead : -@look_ahead
      @current_look += (target_look - @current_look) * @look_ahead_speed
      
      # Apply look ahead to target offset
      @target_off_x = @current_look
      
      # Adjust for ground/air
      if @target.grounded?
        # Normal ground behavior
        @target_off_y = 0
      else
        # When jumping/falling, keep player higher in frame
        jump_offset = [@target.vy * 0.5, 50].min
        @target_off_y = jump_offset
      end
      
      # Dynamic zoom based on speed
      speed_factor = @target.vx.abs / @target.max_speed
      target_zoom = 1.0 - (speed_factor * 0.2)  # Zoom out slightly at high speed
      zoom_to(target_zoom)
    end
    
    super
  end
  
  def apply
    # Ensure minimum height is maintained
    min_zoom = (@min_height / px_hei).ceil
    @target_zoom = [@target_zoom, min_zoom].max
    
    super
  end
end
```

## Next Steps

- [Screen Effects](./04_screen_effects.md)
- [Zoom and Viewport Control](./03_zoom_viewport.md)
- [Entity Tracking](./02_entity_tracking.md)
- [Back to Overview](./01_overview.md)
