# Physics System

The physics system in Hoard provides a flexible framework for handling movement, forces, and velocities in 2D space. It's built around two main classes: `Velocity` and `VelocityArray`.

## Table of Contents

1. [Overview](#overview)
2. [Velocity Class](#velocity-class)
   - [Basic Usage](#basic-usage)
   - [Properties](#velocity-properties)
   - [Methods](#velocity-methods)
   - [Example: Projectile with Drag](#example-projectile-with-drag)
3. [VelocityArray Class](#velocityarray-class)
   - [Basic Usage](#velocityarray-basic-usage)
   - [Methods](#velocityarray-methods)
   - [Example: Multiple Forces](#example-multiple-forces)
4. [Integration with Entities](#integration-with-entities)
5. [Best Practices](#best-practices)

## Overview

The physics system is designed to be:
- **Flexible**: Combine multiple velocities with different frictions
- **Efficient**: Automatic cleanup of near-zero velocities
- **Easy to Use**: Intuitive API for common physics operations
- **Extensible**: Create complex movement behaviors by composing simple velocities

## Velocity Class

The `Velocity` class represents a 2D vector with friction applied each frame. It's ideal for implementing various movement behaviors like player movement, projectiles, or physics-based objects.

### Basic Usage

```ruby
# Create a new velocity with default friction (1.0 = no friction)
velocity = Hoard::Phys::Velocity.new

# Set initial velocity
velocity.x = 5.0
velocity.y = 10.0

# Apply friction (0.9 = 10% reduction per frame)
velocity.frict = 0.9

# In your update loop
velocity.update
```

### Velocity Properties

- `x`, `y`: Current velocity components
- `frict`: Friction coefficient (0.0 to 1.0)
- `frict_x`, `frict_y`: Separate friction for each axis
- `ang`: Current angle in radians (read-only)
- `len`: Current length/magnitude (read-only)
- `dir_x`, `dir_y`: Direction components (-1, 0, or 1)

### Velocity Methods

#### Movement
- `set(x, y)`: Set velocity components
- `add_xy(dx, dy)`: Add to current velocity
- `add_ang(angle, speed)`: Add velocity in a specific direction
- `set_ang(angle, speed)`: Set velocity in a specific direction
- `rotate(angle_increment)`: Rotate velocity

#### Physics
- `update(frict_override = -1.0)`: Apply friction and clear near-zero values
- `clear()`: Reset velocity to zero
- `zero?`: Check if velocity is effectively zero

#### Math Operations
- `mul(factor)`: Multiply velocity by a scalar
- `mul_xy(fx, fy)`: Multiply x and y components separately
- `*`: Alias for `mul`

### Example: Projectile with Drag

```ruby
class Projectile < Hoard::Entity
  def initialize(x, y, angle, speed)
    super()
    set_pos(x, y)
    
    # Create velocity with air resistance
    @velocity = Hoard::Phys::Velocity.new
    @velocity.set_ang(angle, speed)
    @velocity.frict = 0.98  # 2% speed reduction per frame
    
    # Gravity
    @gravity = Hoard::Phys::Velocity.create_frict(1.0)
    @gravity.y = 0.5
  end
  
  def update
    # Apply gravity
    @velocity.add_xy(@gravity.x, @velocity.frict_y * @gravity.y)
    
    # Update position
    self.x += @velocity.x
    self.y += @velocity.y
    
    # Apply friction
    @velocity.update
    
    # Destroy when stopped
    destroy if @velocity.zero?
  end
  
  def render
    # Draw projectile
    args.outputs.sprites << {
      x: x, y: y, w: 8, h: 8,
      path: 'sprites/projectile.png'
    }
  end
end
```

## VelocityArray Class

The `VelocityArray` is a specialized array for managing multiple `Velocity` instances. It provides convenient methods for applying operations to all velocities in the collection.

### VelocityArray Basic Usage

```ruby
# Create a new velocity array
velocities = Hoard::Phys::VelocityArray.new

# Add some velocities
vel1 = Hoard::Phys::Velocity.create_frict(0.9)
vel2 = Hoard::Phys::Velocity.create_frict(0.95)
velocities << vel1 << vel2

# Apply forces to all
velocities.each { |v| v.add_xy(0, -0.5) }  # Gravity

# Update all
velocities.each(&:update)
```

### VelocityArray Methods

- `sum_x`, `sum_y`: Sum of all x or y components
- `mul_all(factor)`: Multiply all velocities by a scalar
- `mul_all_x(fx)`, `mul_all_y(fy)`: Multiply x or y components
- `clear_all`: Reset all velocities to zero
- `remove_zeroes`: Remove all zero velocities

### Example: Multiple Forces

```ruby
class Spaceship < Hoard::Entity
  def initialize
    super
    @velocities = Hoard::Phys::VelocityArray.new
    
    # Main engine (forward/backward)
    @engine = Hoard::Phys::Velocity.create_frict(0.95)
    @velocities << @engine
    
    # Side thrusters (strafe)
    @strafe = Hoard::Phys::Velocity.create_frict(0.9)
    @velocities << @strafe
    
    # Rotation
    @rotation = 0
    @rotation_speed = 0
    @rotation_friction = 0.9
  end
  
  def update
    # Apply engine forces
    if args.inputs.keyboard.key_held.up
      @engine.add_ang(@rotation, 0.1)
    elsif args.inputs.keyboard.key_held.down
      @engine.add_ang(@rotation + Math::PI, 0.1)
    end
    
    # Strafe
    if args.inputs.keyboard.key_held.left
      @strafe.add_ang(@rotation - Math::PI/2, 0.05)
    elsif args.inputs.keyboard.key_held.right
      @strafe.add_ang(@rotation + Math::PI/2, 0.05)
    end
    
    # Rotation
    if args.inputs.keyboard.key_held.q
      @rotation_speed -= 0.05
    elsif args.inputs.keyboard.key_held.e
      @rotation_speed += 0.05
    end
    
    # Apply rotation
    @rotation += @rotation_speed
    @rotation_speed *= @rotation_friction
    
    # Update all velocities
    @velocities.each(&:update)
    
    # Apply movement
    self.x += @velocities.sum_x
    self.y += @velocities.sum_y
    
    # Clean up near-zero velocities
    @velocities.remove_zeroes
  end
  
  def render
    # Draw spaceship rotated
    args.outputs.sprites << {
      x: x, y: y, w: 32, h: 32,
      path: 'sprites/spaceship.png',
      angle: @rotation * 180 / Math::PI  # Convert to degrees
    }
    
    # Draw debug info
    if $debug
      @velocities.each_with_index do |v, i|
        args.outputs.lines << {
          x: x, y: y,
          x2: x + v.x * 10, y2: y + v.y * 10,
          r: 255, g: 0, b: 0
        }
      end
    end
  end
end
```

## Integration with Entities

The physics system works seamlessly with Hoard's `Entity` class. Here's how to integrate it:

```ruby
class PhysicsEntity < Hoard::Entity
  def initialize
    super
    
    # Create velocity components
    @velocities = Hoard::Phys::VelocityArray.new
    
    # Base movement
    @movement = Hoard::Phys::Velocity.create_frict(0.85)
    @velocities << @movement
    
    # Bounce effect
    @bounce = Hoard::Phys::Velocity.create_frict(0.7)
    @velocities << @bounce
    
    # Custom properties
    @on_ground = false
  end
  
  def update
    # Apply gravity if not on ground
    unless @on_ground
      @movement.y -= 0.5
    end
    
    # Update all velocities
    @velocities.each(&:update)
    
    # Move entity
    move_x(@velocities.sum_x, :collide_x)
    move_y(@velocities.sum_y, :collide_y)
    
    # Check if on ground
    @on_ground = false
  end
  
  def collide_x
    @movement.x *= -0.5  # Bounce off walls
  end
  
  def collide_y
    if @movement.y < 0
      @on_ground = true
    end
    @movement.y *= -0.4  # Bounce off floor/ceiling
  end
  
  def jump(force = 10.0)
    return unless @on_ground
    @movement.y = force
    @on_ground = false
  end
  
  def push(x, y)
    @bounce.add_xy(x, y)
  end
end
```

## Best Practices

1. **Combine Velocities**: Use multiple velocities for different movement aspects (e.g., walking, jumping, knockback)
2. **Appropriate Friction**: Set proper friction values for different behaviors (e.g., 0.9 for air resistance, 0.5 for ground friction)
3. **Clean Up**: Use `remove_zeroes` to clean up unused velocities
4. **Debug Visualization**: Draw velocity vectors when `$debug` is true
5. **Frame-Rate Independence**: Multiply by `tmod` when applying forces for consistent behavior across frame rates
6. **Use VelocityArray**: For complex entities, use `VelocityArray` to manage multiple forces
7. **Separation of Concerns**: Keep physics logic in the update method and rendering in the render method
8. **Optimize**: For many simple objects, consider using a single velocity component

## Performance Considerations

- **Object Pooling**: Reuse `Velocity` objects instead of creating/destroying them
- **Minimize Allocations**: Avoid creating new objects in the update loop
- **Batch Updates**: When possible, update all physics objects in a single pass
- **Spatial Partitioning**: For collision detection, use a spatial grid or quadtree

## Advanced Topics

### Custom Integrators
For more precise physics, you can implement custom integration methods:

```ruby
def verlet_integration(dt)
  # Save previous position
  @prev_x ||= x
  @prev_y ||= y
  
  # Calculate velocity
  vx = x - @prev_x
  vy = y - @prev_y
  
  # Save current position
  old_x, old_y = x, y
  
  # Verlet integration
  new_x = x + vx + @accel_x * dt * dt
  new_y = y + vy + @accel_y * dt * dt
  
  # Update positions
  @prev_x, @prev_y = old_x, old_y
  self.x, self.y = new_x, new_y
  
  # Reset acceleration
  @accel_x = @accel_y = 0
end
```

### Collision Response
For more realistic collisions:

```ruby
def resolve_collision(other, normal_x, normal_y)
  # Calculate relative velocity
  rel_vel_x = @velocity.x - other.velocity.x
  rel_vel_y = @velocity.y - other.velocity.y
  
  # Calculate relative velocity in terms of the normal direction
  vel_along_normal = rel_vel_x * normal_x + rel_vel_y * normal_y
  
  # Don't resolve if objects are separating
  return if vel_along_normal > 0
  
  # Calculate restitution (bounciness)
  e = [@restitution, other.restitution].min
  
  # Calculate impulse scalar
  j = -(1 + e) * vel_along_normal
  j /= 1.0 / @mass + 1.0 / other.mass
  
  # Apply impulse
  impulse_x = j * normal_x
  impulse_y = j * normal_y
  
  # Change velocities
  inv_mass = 1.0 / @mass
  @velocity.x += impulse_x * inv_mass
  @velocity.y += impulse_y * inv_mass
  
  other_inv_mass = 1.0 / other.mass
  other.velocity.x -= impulse_x * other_inv_mass
  other.velocity.y -= impulse_y * other_inv_mass
end
```

This documentation covers the core functionality of Hoard's physics system. For more advanced usage, refer to the source code and experiment with different combinations of velocities and forces.
