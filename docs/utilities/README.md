# Utility Classes

The Hoard library includes several utility classes that provide common game development functionality. This document covers the key utility classes and their usage.

## Table of Contents

1. [Cooldown](#cooldown)
   - [Basic Usage](#cooldown-basic-usage)
   - [API Reference](#cooldown-api)
   - [Examples](#cooldown-examples)

2. [Tweenie](#tweenie)
   - [Basic Usage](#tweenie-basic-usage)
   - [Tween Types](#tween-types)
   - [API Reference](#tweenie-api)
   - [Examples](#tweenie-examples)

3. [Serializable](#serializable)
   - [Basic Usage](#serializable-basic-usage)
   - [API Reference](#serializable-api)

4. [Delayer](#delayer)
   - [Basic Usage](#delayer-basic-usage)
   - [API Reference](#delayer-api)

## Cooldown

The `Cooldown` class provides a flexible way to manage timed events and cooldowns in your game.

### Cooldown Basic Usage

```ruby
# Create a new cooldown manager
cooldown = Hoard::Cooldown.new(fps: 60)  # 60 updates per second

# Set a cooldown for 2 seconds
cooldown.set_s(:ability_ready, 2.0)

# In your update loop
cooldown.update(1.0/60)  # Update with delta time

# Check if cooldown is complete
if cooldown.has?(:ability_ready)
  # Ability is ready
  cooldown.set_s(:ability_ready, 2.0)  # Reset cooldown
end
```

### Cooldown API

#### Initialization
- `Cooldown.new(fps: 60, max_size: 512)` - Create a new cooldown manager
  - `fps`: The frame rate the cooldown will use for calculations
  - `max_size`: Maximum number of concurrent cooldowns

#### Time Management
- `set_s(key, seconds, allow_lower: true, on_complete: nil)` - Set a cooldown in seconds
- `set_ms(key, milliseconds, allow_lower: true, on_complete: nil)` - Set a cooldown in milliseconds
- `set_frames(key, frames, allow_lower: true, on_complete: nil)` - Set a cooldown in frames
- `get(key)` - Get remaining time in seconds (nil if expired)
- `get_frames(key)` - Get remaining time in frames
- `get_ratio(key)` - Get completion ratio (0 to 1)
- `has?(key)` - Check if cooldown exists and is active
- `unset(key)` - Remove a cooldown
- `clear` - Clear all cooldowns
- `update(delta_time)` - Update all cooldowns

### Cooldown Examples

#### Multiple Cooldowns
```ruby
class Player
  def initialize
    @cooldown = Hoard::Cooldown.new
    @cooldown.set_s(:shoot, 0.5)  # 500ms between shots
    @cooldown.set_s(:dash, 1.0)   # 1 second dash cooldown
  end
  
  def update(dt)
    @cooldown.update(dt)
  end
  
  def shoot
    return if @cooldown.has?(:shoot)
    # Shoot logic here
    @cooldown.set_s(:shoot, 0.5)
  end
  
  def dash
    return if @cooldown.has?(:dash)
    # Dash logic here
    @cooldown.set_s(:dash, 1.0)
  end
end
```

#### Cooldown with Callback
```ruby
cooldown = Hoard::Cooldown.new

# Set a cooldown that calls a function when complete
cooldown.set_s(:ability, 3.0, on_complete: -> { puts "Ability ready!" })

# In your update loop
cooldown.update(delta_time)
```

## Tweenie

The `Tweenie` class provides smooth animations and transitions between values.

### Tweenie Basic Usage

```ruby
# Create a tween manager
tweenie = Hoard::Tweenie.new

# Create a tween for a sprite's x position
tween = tweenie.create(
  -> { sprite.x },           # Getter
  -> (v) { sprite.x = v },  # Setter
  nil,                      # From (nil = current value)
  100,                      # To
  :ease_out,                # Easing type
  1000                      # Duration in ms
)

# In your update loop
tweenie.update(delta_time)
```

### Tween Types

Hoard provides several built-in tween types:

| Type | Description |
|------|-------------|
| `:linear` | Linear interpolation |
| `:ease` | Smooth start and end |
| `:ease_in` | Smooth start |
| `:ease_out` | Smooth end |
| `:bounce` | Bounce effect at end |
| `:elastic` | Elastic effect at end |
| `:back` | Overshoot and settle |

### Tweenie API

#### Initialization
- `Tweenie.new(fps: 60)` - Create a new tween manager

#### Creating Tweens
- `create(getter, setter, from, to, type = :ease, duration_ms = 1000, allow_duplicates = false)`
  - `getter`: Lambda that returns the current value
  - `setter`: Lambda that sets the value
  - `from`: Starting value (nil for current value)
  - `to`: Target value
  - `type`: Tween type (see above)
  - `duration_ms`: Duration in milliseconds
  - `allow_duplicates`: Allow multiple tweens for the same property

#### Tween Control
- `tween.pause` - Pause the tween
- `tween.resume` - Resume the tween
- `tween.complete` - Jump to completion
- `tween.cancel` - Cancel the tween
- `tween.on_complete { ... }` - Set completion callback
- `tween.on_update { |value| ... }` - Set update callback

### Tweenie Examples

#### Animate Multiple Properties
```ruby
# Animate position and alpha
tweenie.create(
  -> { [sprite.x, sprite.y, sprite.a] },
  -> (x, y, a) { 
    sprite.x = x
    sprite.y = y
    sprite.a = a
  },
  nil,                           # Current values
  [400, 300, 0],                  # Target values
  :ease_out,                      
  1000
)
```

#### Chained Animations
```ruby
t1 = tweenie.create(
  -> { sprite.x },
  -> (v) { sprite.x = v },
  100, 400, :ease_out, 500
)

t1.on_complete do
  # Start second tween when first completes
  tweenie.create(
    -> { sprite.y },
    -> (v) { sprite.y = v },
    100, 400, :bounce, 1000
  )
end
```

## Serializable

The `Serializable` module provides easy object serialization for saving and loading game state.

### Serializable Basic Usage

```ruby
class Player
  include Hoard::Serializable
  
  attr_accessor :x, :y, :health, :inventory
  
  def initialize
    @x = 0
    @y = 0
    @health = 100
    @inventory = []
  end
end

# Save
player = Player.new
save_data = player.serialize

# Load
new_player = Player.deserialize(save_data)
```

## Delayer

The `Delayer` class helps manage delayed execution of code.

### Delayer Basic Usage

```ruby
delayer = Hoard::Delayer.new

# Add a delayed action
delayer.add(2.0) { puts "This runs after 2 seconds" }

# In your update loop
delayer.update(delta_time)
```

### Delayer API

- `add(delay_seconds, &block)` - Add a delayed action
- `add_frames(frames, &block)` - Add a delayed action in frames
- `clear` - Clear all pending actions
- `update(delta_time)` - Update the delayer

## Best Practices

1. **Reuse Objects**: Reuse Cooldown and Tweenie instances instead of creating new ones
2. **Use Callbacks**: Leverage callbacks for cleaner code
3. **Pooling**: Use object pooling for frequently created/destroyed tweens
4. **Naming**: Use descriptive names for cooldown keys
5. **Error Handling**: Always check if a tween exists before manipulating it
6. **Performance**: Be mindful of the number of active tweens for performance

## Advanced Topics

### Custom Easing Functions

```ruby
# Define a custom easing function
def my_ease(t)
  t * t * (3 - 2 * t)  # Smoothstep
end

# Use it in a tween
tweenie.create(
  -> { value },
  -> (v) { value = v },
  0, 100, 
  method(:my_ease),  # Use custom easing
  1000
)
```

### Tweening Complex Objects

```ruby
# Tween a color
start_color = { r: 255, g: 0, b: 0 }
target_color = { r: 0, g: 0, b: 255 }

tweenie.create(
  -> { start_color },
  -> (color) { 
    start_color = color
    # Update your renderer with the new color
  },
  nil,
  target_color,
  :ease_in_out,
  2000
)
```

This documentation covers the core utility classes in the Hoard library. For more advanced usage, refer to the source code and experiment with different configurations.
