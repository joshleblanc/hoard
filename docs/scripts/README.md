# Built-in Scripts

Hoard comes with a collection of reusable scripts that implement common game mechanics. These can be added to entities to provide specific behaviors.

## Table of Contents

1. [Physics](#physics)
   - [GravityScript](#gravityscript)
   - [JumpScript](#jumpscript)
   - [PlatformerControls](#platformercontrols)

2. [Gameplay](#gameplay)
   - [HealthScript](#healthscript)
   - [InventoryScript](#inventoryscript)
   - [PickupScript](#pickupscript)
   - [ShopScript](#shopscript)

3. [Visual Effects](#visual-effects)
   - [AnimationScript](#animationscript)
   - [EffectScript](#effectscript)
   - [DebugRenderScript](#debugrenderscript)

4. [Level Design](#level-design)
   - [LdtkEntityScript](#ldtkentityscript)
   - [MoveToNeighbourScript](#movetoneighbourscript)

## Physics

### GravityScript

Applies gravity to the entity.

**Properties:**
- `gravity`: Gravity force (default: 0.5)
- `max_fall_speed`: Maximum falling speed (default: 16)
- `grounded`: Readonly, true if entity is on ground

**Example:**
```ruby
entity.add_script(GravityScript.new(
  gravity: 0.8,
  max_fall_speed: 20
))
```

### JumpScript

Handles jumping mechanics.

**Properties:**
- `jump_force`: Jump force (default: 8)
- `jump_duration`: How long jump force is applied (default: 0.2)
- `max_jumps`: Maximum consecutive jumps (default: 1)
- `coyote_time`: Time after leaving ground when jump is still allowed (default: 0.1)

**Methods:**
- `jump`: Make the entity jump
- `can_jump?`: Check if entity can jump

**Example:**
```ruby
jump = JumpScript.new(
  jump_force: 10,
  max_jumps: 2
)
entity.add_script(jump)

# In input handling:
jump.jump if inputs.keyboard.key_down.space
```

### PlatformerControls

Provides platformer-style movement controls.

**Properties:**
- `move_speed`: Movement speed (default: 3)
- `acceleration`: How quickly entity reaches max speed (default: 0.2)
- `deceleration`: How quickly entity stops (default: 0.4)
- `air_control`: Movement control in air (0.0 to 1.0, default: 0.5)

**Example:**
```ruby
entity.add_script(PlatformerControls.new(
  move_speed: 4,
  acceleration: 0.3
))
```

## Gameplay

### HealthScript

Manages health and damage.

**Properties:**
- `health`: Current health
- `max_health`: Maximum health
- `invincible`: If true, can't take damage
- `invincibility_duration`: How long after taking damage before can be hit again (default: 1.0)

**Methods:**
- `take_damage(amount)`: Reduce health
- `heal(amount)`: Restore health
- `dead?`: Check if health <= 0

**Example:**
```ruby
health = HealthScript.new(100)  # 100 max health
entity.add_script(health)

# Take damage
health.take_damage(20)


# Check if dead
if health.dead?
  # Handle death
end
```

### InventoryScript

Manages an entity's inventory.

**Properties:**
- `slots`: Array of items
- `capacity`: Maximum number of items
- `selected_index`: Currently selected item index

**Methods:**
- `add_item(item)`: Add item to inventory
- `remove_item(index)`: Remove item at index
- `get_item(index)`: Get item at index
- `has_item?(item_type)`: Check if inventory has item of type

**Example:**
```ruby
inventory = InventoryScript.new(8)  # 8 slots
entity.add_script(inventory)

# Add items
inventory.add_item(Item.new(:health_potion))
inventory.add_item(Item.new(:sword))

# Use selected item
inventory.use_selected
```

### PickupScript

Handles item collection.

**Properties:**
- `pickup_radius`: How close entity needs to be to pick up (default: 16)
- `auto_pickup`: If true, automatically picks up items in radius (default: true)

**Example:**
```ruby
# On player
player.add_script(PickupScript.new(
  pickup_radius: 24,
  auto_pickup: true
))

# On item
item.add_script(PickupScript::ItemScript.new(:health_potion, 1))
```

### ShopScript

Handles buying and selling items.

**Properties:**
- `items`: Array of items for sale
- `buy_multiplier`: Price multiplier when buying (default: 1.0)
- `sell_multiplier`: Price multiplier when selling (default: 0.5)

**Methods:**
- `buy(item_index, buyer)`: Buy item at index
- `sell(item, seller)`: Sell item to shop
- `can_afford?(item_index, buyer)`: Check if buyer can afford item

**Example:**
```ruby
shop = ShopScript.new([
  { type: :health_potion, price: 50 },
  { type: :sword, price: 200 }
])
shop_entity.add_script(shop)

# In player interaction
if shop.can_afford?(0, player)
  shop.buy(0, player)
end
```

## Visual Effects

### AnimationScript

Manages sprite animations.

**Properties:**
- `animations`: Hash of animation definitions
- `current_animation`: Name of current animation
- `frame_index`: Current frame index
- `looping`: If current animation loops

**Methods:**
- `play_animation(name, force_restart = false)`: Play animation
- `stop_animation`: Stop current animation
- `animation_done?`: Check if current animation is complete

**Example:**
```ruby
anim = AnimationScript.new
anim.animations = {
  idle: { frames: 4, duration: 0.5, loop: true },
  run: { frames: 6, duration: 0.4, loop: true },
  jump: { frames: 2, duration: 0.2, loop: false }
}
entity.add_script(anim)

# Play animation
anim.play_animation(:run)
```

### EffectScript

Applies visual effects to entities.

**Effects:**
- Flash (temporary color change)
- Shake (screen/entity shake)
- Fade (fade in/out)
- Scale (pulse/grow/shrink)

**Example:**
```ruby
effect = EffectScript.new
effect.flash(color: [255, 0, 0], duration: 0.5)
effect.shake(intensity: 5, duration: 0.3)
entity.add_script(effect)
```

### DebugRenderScript

Draws debug information for an entity.

**Options:**
- `show_bounds`: Show collision bounds (default: true)
- `show_origin`: Show origin point (default: true)
- `show_velocities`: Show velocity vectors (default: false)
- `show_name`: Show entity class name (default: true)

**Example:**
```ruby
# For development only
if $debug
  entity.add_script(DebugRenderScript.new(
    show_bounds: true,
    show_velocities: true
  ))
end
```

## Level Design

### LdtkEntityScript

Integrates with LDtk level editor entities.

**Properties:**
- `entity_def`: The LDtk entity definition
- `custom_fields`: Access to custom entity fields

**Example:**
```ruby
# In level loading code
level.entities.each do |ldtk_entity|
  entity = Entity.new
  entity.add_script(LdtkEntityScript.new(ldtk_entity))
  
  # Access custom fields
  if enemy_type = ldtk_entity.custom_fields[:enemy_type]
    # Configure based on type
  end
  
  game.add_entity(entity)
end
```

### MoveToNeighbourScript

Moves entity to neighboring rooms/levels.

**Properties:**
- `target_level`: Name of target level
- `spawn_point`: Spawn point identifier in target level
- `transition_effect`: Visual effect during transition

**Example:**
```ruby
door = Entity.new
door.add_script(MoveToNeighbourScript.new(
  target_level: "dungeon_2",
  spawn_point: "entrance",
  transition_effect: :fade
))
```

## Creating Custom Scripts

To create a custom script:

1. Create a class that inherits from `Script`
2. Implement required methods (`update`, etc.)
3. Add it to an entity with `add_script`

**Example:**
```ruby
class MyCustomScript < Script
  def initialize(some_parameter)
    super()
    @parameter = some_parameter
  end
  
  def update
    # Custom behavior here
    entity.x += 1 if entity.get_script(PlayerControls)&.moving_right?
  end
  
  def on_remove
    # Cleanup
  end
end

# Usage
entity.add_script(MyCustomScript.new(123))
```

## Best Practices

1. **Single Responsibility**: Each script should handle one specific behavior
2. **Configuration**: Use initializer parameters for configuration
3. **Cleanup**: Implement `on_remove` to clean up resources
4. **Events**: Use `broadcast_to_scripts` for script communication
5. **Performance**: Keep update logic efficient
