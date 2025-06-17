# Entity Class

The `Entity` class is a core component of Hoard, representing game objects with position, size, and visual representation. It extends the `Process` class and includes the `Scriptable` and `Widgetable` modules.

## Overview

Entities are the primary objects in a Hoard game, providing:
- Position and movement in 2D space
- Visual representation (sprites, animations)
- Collision detection
- Scripting capabilities
- UI widget integration

## Core Properties

### Position and Movement
- `cx`, `cy`: Grid coordinates (integer)
- `xr`, `yr`: Ratio within grid cell (0.0 to 1.0)
- `xx`, `yy`: Exact position in grid units (cx + xr, cy + yr)
- `x`, `y`: Pixel position (xx * GRID, yy * GRID)
- `dx`, `dy`: Movement deltas
- `dir`: Facing direction (1 for right, -1 for left)

### Visual Properties
- `w`, `h`: Width and height in pixels
- `tile_w`, `tile_h`: Size of individual tiles in the sprite sheet
- `scale_x`, `scale_y`: Scaling factors
- `squash_x`, `squash_y`: Squash and stretch effects
- `flip_horizontally`, `flip_vertically`: Sprite flipping
- `visible`: Controls rendering

### Physics
- `v_base`: Base velocity
- `v_bump`: Bump/knockback velocity
- `collidable`: Whether the entity participates in collisions

## Key Methods

### Position Management
- `set_pos_case(x, y)`: Set position using grid coordinates
- `move_x(amount)`: Move along X-axis
- `move_y(amount)`: Move along Y-axis
- `center_x`, `center_y`: Get center position

### Collision
- `check_collision(entity, cx, cy)`: Check for collision with another entity
- `collides_with?(other)`: Check if colliding with another entity
- `on_collision(other)`: Called when a collision occurs

### Animation
- `play_animation(name, force_restart = false)`: Play an animation
- `stop_animation`: Stop current animation
- `animation_done?`: Check if current animation is complete

## Example Usage

```ruby
class Player < Hoard::Entity
  def initialize(x, y)
    super()
    set_pos_case(x, y)
    @w = @h = 16
    @path = 'sprites/player.png'
    @collidable = true
    
    # Add movement scripts
    add_script Scripts::PlatformerControls.new
    add_script Scripts::Gravity.new
    
    # Set up animations
    @animations = {
      idle: { frames: 4, duration: 0.5, loop: true },
      run: { frames: 6, duration: 0.4, loop: true },
      jump: { frames: 2, duration: 0.2, loop: false }
    }
    
    play_animation(:idle)
  end
  
  def update
    super
    
    # Update animation based on state
    if @v_base.y != 0
      play_animation(:jump) unless current_animation == :jump
    elsif @v_base.x != 0
      play_animation(:run)
      @flip_horizontally = @v_base.x < 0
    else
      play_animation(:idle)
    end
  end
end
```

## Best Practices

1. **Use Components**: Prefer adding scripts over subclassing for common behaviors
2. **Grid vs Pixel Coordinates**: Use grid coordinates (cx, cy) for game logic, pixel coordinates (x, y) for rendering
3. **Collision Layers**: Use tags or layers to manage which entities should collide
4. **Animation States**: Centralize animation state management in the update method
5. **Cleanup**: Always call super in overridden methods to ensure proper cleanup

## Integration with LDtk

Entities can be created from LDtk entities by using the `LdtkEntityScript`:

```ruby
# In your level loading code
entity_defs.each do |entity_def|
  entity = Entity.new
  entity.add_script Scripts::LdtkEntityScript.new(entity_def)
  # Add to your game world
  add_child(entity)
end
```
