# Scriptable Module

The `Scriptable` module provides a flexible component system for adding behaviors to entities. It's a mixin that enables the entity-component pattern in Hoard.

## Overview

- Allows adding multiple behaviors to entities
- Enables clean separation of concerns
- Supports message passing between components
- Provides lifecycle hooks

## Core Methods

### Script Management
- `add_script(script)`: Add a script to the entity
- `remove_script(script)`: Remove a script
- `has_script?(klass)`: Check if a script of given class exists
- `get_script(klass)`: Get the first script of given class

### Lifecycle Hooks
Scripts can implement these methods to respond to entity events:
- `on_add`: Called when script is added to an entity
- `on_remove`: Called when script is removed
- `update`: Called every frame
- `pre_update`: Called before the entity updates
- `post_update`: Called after the entity updates
- `render`: Called when the entity renders

## Example Script

```ruby
class HealthScript < Script
  attr_accessor :health, :max_health
  
  def initialize(max_health = 100)
    super()
    @max_health = max_health
    @health = max_health
    @invincible = false
  end
  
  def take_damage(amount)
    return if @invincible || @health <= 0
    
    @health -= amount
    
    if @health <= 0
      entity.broadcast_to_scripts(:on_death)
    else
      # Flash effect
      entity.tint = [255, 100, 100, 200]
      entity.tw.merge!(
        entity, 
        [:tint],
        10, 
        { tint: [255, 255, 255, 255] },
        :io_quad
      )
      
      # Temporary invincibility
      @invincible = true
      entity.cd.set_s("invincible", 1.0) { @invincible = false }
    end
  end
  
  def heal(amount)
    @health = [@health + amount, @max_health].min
  end
  
  def dead?
    @health <= 0
  end
end
```

## Using Scripts

### Adding Scripts
```ruby
# Create an entity
player = Entity.new

# Add scripts
player.add_script(HealthScript.new(200))
player.add_script(PlayerControls.new)
player.add_script(Inventory.new(10))  # 10 slots
```

### Accessing Scripts
```ruby
# Get health script
health = player.get_script(HealthScript)

# Check if player is dead
if health&.dead?
  game_over! 
end

# Heal player
health&.heal(50)
```

### Script Communication
Scripts can communicate through the entity:

```ruby
# In MovementScript
def update
  # Check if entity can move (e.g., not stunned)
  if entity.get_script(StunEffect)&.active?
    return
  end
  
  # Normal movement logic
  entity.x += speed * entity.direction
end

# In StunScript
def stun(duration)
  @stun_until = Time.now + duration
  entity.broadcast_to_scripts(:on_stun, duration)
end

def active?
  @stun_until && Time.now < @stun_until
end
```

## Built-in Scripts

Hoard comes with several useful built-in scripts:

### Physics
- `GravityScript`: Applies gravity to the entity
- `JumpScript`: Handles jumping mechanics
- `PlatformerControls`: Basic platformer movement

### Gameplay
- `HealthScript`: Manages health and damage
- `Inventory`: Item management
- `PickupScript`: Handles item collection
- `ShopScript`: Buying/selling items

### Visual Effects
- `AnimationScript`: Handles sprite animations
- `EffectScript`: Visual effects
- `DebugRenderScript`: Debug visualization

## Best Practices

1. **Single Responsibility**: Each script should handle one specific behavior
2. **Loose Coupling**: Scripts should not directly depend on each other
3. **Event-Driven**: Use `broadcast_to_scripts` for communication
4. **Cleanup**: Implement `on_remove` to clean up resources
5. **Configuration**: Pass configuration to scripts through initializer

## Advanced Usage

### Script Dependencies
```ruby
class DoubleJumpScript < Script
  def on_add
    # Require JumpScript
    @jump = entity.get_script(JumpScript)
    if !@jump
      raise "DoubleJumpScript requires JumpScript"
    end
    
    # Track jumps
    @jumps_remaining = 1
    
    # Listen for jump events
    entity.on(:jump) do
      @jumps_remaining -= 1
    end
    
    entity.on(:land) do
      @jumps_remaining = 1
    end
  end
  
  def can_jump?
    @jumps_remaining > 0
  end
  
  def jump
    @jump.jump
    @jumps_remaining -= 1
  end
end
```

### Script Templates
```ruby
# Base class for all game scripts
class GameScript < Script
  # Common properties and methods
end

# Base class for player scripts
class PlayerScript < GameScript
  def player
    @player ||= entity.get_script(PlayerComponent)
  end
  
  def controls
    @controls ||= entity.get_script(PlayerControls)
  end
end
```
