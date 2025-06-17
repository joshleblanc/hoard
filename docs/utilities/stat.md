# Stat System

The `Hoard::Stat` class provides a simple way to manage numeric values with min/max constraints, commonly used for attributes like health, mana, or any other game statistic.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [API Reference](#api-reference)
4. [Examples](#examples)
   - [Health Bar](#health-bar-example)
   - [Cooldown Timer](#cooldown-timer-example)
   - [Experience Points](#experience-points-example)
5. [Best Practices](#best-practices)

## Overview

The `Stat` class helps you:
- Track a numeric value with optional min/max bounds
- Easily reset values to their maximum
- Initialize with different value ranges
- Prevent values from going out of bounds

## Basic Usage

```ruby
# Create a new stat with default values (0, min: 0, max: 0)
health = Hoard::Stat.new

# Initialize with just a maximum (min: 0, value: max)
health.init_max_on_max(100)  # value: 100, min: 0, max: 100

# Or specify all values explicitly
mana = Hoard::Stat.new
mana.init(50, 0, 100)  # value: 50, min: 0, max: 100

# Reset to max value
mana.reset!  # value is now 100
```

## API Reference

### Initialization

```ruby
# Create a new stat (all values start at 0)
stat = Hoard::Stat.new

# Initialize with value and max (min defaults to 0)
stat.init(value, max)

# Initialize with value, min, and max
stat.init(value, min, max)

# Initialize with max value (value = max, min = 0)
stat.init_max_on_max(max)
```

### Properties

- `v`: Current value (read/write)
- `min`: Minimum allowed value (read/write)
- `max`: Maximum allowed value (read/write)

### Methods

- `reset!`: Sets the current value to the maximum

## Examples

### Health Bar Example

```ruby
class Player
  attr_reader :health
  
  def initialize
    @health = Hoard::Stat.new
    @health.init(100, 0, 100)  # Start with 100/100 health
  end
  
  def take_damage(amount)
    @health.v = [@health.v - amount, @health.min].max
    
    if @health.v <= 0
      die
    end
  end
  
  def heal(amount)
    @health.v = [@health.v + amount, @health.max].min
  end
  
  def heal_full
    @health.reset!
  end
  
  def health_percent
    @health.v.to_f / @health.max
  end
  
  def draw
    # Draw health bar
    bar_width = 100
    filled_width = (bar_width * health_percent).to_i
    
    # Background
    $args.outputs.solids << {
      x: 10, y: 10, w: bar_width, h: 20,
      r: 50, g: 50, b: 50
    }
    
    # Health fill
    $args.outputs.solids << {
      x: 10, y: 10, w: filled_width, h: 20,
      r: 200, g: 50, b: 50
    }
    
    # Text
    $args.outputs.labels << {
      x: 10 + bar_width / 2, y: 25, text: "#{@health.v}/#{@health.max}",
      size_enum: -2, alignment_enum: 1
    }
  end
end
```

### Cooldown Timer Example

```ruby
class Ability
  attr_reader :cooldown
  
  def initialize
    @cooldown = Hoard::Stat.new
    @cooldown.init(0, 0, 180)  # 3 second cooldown at 60 FPS
    @ready = true
  end
  
  def update
    return if @ready
    
    @cooldown.v -= 1
    if @cooldown.v <= @cooldown.min
      @cooldown.v = @cooldown.min
      @ready = true
    end
  end
  
  def use
    return false unless @ready
    
    # Use ability
    puts "Ability used!"
    
    # Start cooldown
    @cooldown.reset!
    @ready = false
    
    true
  end
  
  def cooldown_percent
    1.0 - (@cooldown.v.to_f / @cooldown.max)
  end
  
  def draw(x, y)
    # Draw cooldown indicator
    if @ready
      # Ready state
      $args.outputs.solids << { x: x, y: y, w: 50, h: 50, r: 0, g: 200, b: 0 }
    else
      # Cooldown state
      $args.outputs.solids << { x: x, y: y, w: 50, h: 50, r: 100, g: 100, b: 100 }
      $args.outputs.primitives << {
        x: x, y: y, w: 50, h: 50 * cooldown_percent,
        path: :pixel, r: 0, g: 0, b: 0, a: 128
      }.sprite_clip_rect
    end
  end
end
```

### Experience Points Example

```ruby
class Player
  attr_reader :level, :xp
  
  def initialize
    @level = 1
    @xp = Hoard::Stat.new
    update_xp_requirements
  end
  
  def add_xp(amount)
    @xp.v += amount
    
    # Level up if enough XP
    while @xp.v >= @xp.max
      level_up
    end
  end
  
  def level_up
    @level += 1
    xp_overflow = @xp.v - @xp.max
    update_xp_requirements
    @xp.v = xp_overflow
    
    puts "Level up! Now level #{@level}"
  end
  
  def update_xp_requirements
    base_xp = 100
    @xp.init(0, 0, base_xp * (1.5 ** (@level - 1)).to_i)
  end
  
  def xp_percent
    @xp.v.to_f / @xp.max
  end
  
  def draw(x, y)
    # Draw XP bar
    bar_width = 200
    filled_width = (bar_width * xp_percent).to_i
    
    # Background
    $args.outputs.solids << {
      x: x, y: y, w: bar_width, h: 10,
      r: 50, g: 50, b: 50
    }
    
    # XP fill
    $args.outputs.solids << {
      x: x, y: y, w: filled_width, h: 10,
      r: 100, g: 100, b: 200
    }
    
    # Text
    $args.outputs.labels << {
      x: x + bar_width / 2, y: y + 20, text: "Level #{@level}: #{@xp.v}/#{@xp.max} XP",
      size_enum: -2, alignment_enum: 1
    }
  end
end
```

## Best Practices

1. **Encapsulation**: Consider wrapping `Hoard::Stat` in your own classes to add domain-specific behavior
2. **Event Hooks**: Add callbacks for when values change or reach min/max
3. **Serialization**: Include stat values when saving/loading game state
4. **Validation**: Add validation when setting values directly
5. **Debugging**: Add `to_s` or `inspect` methods for easier debugging
6. **Performance**: For frequently updated stats, consider using primitive types for critical paths

### Example: Enhanced Stat Class

```ruby
class GameStat < Hoard::Stat
  def initialize(min = 0, max = 100, value = nil)
    super()
    @on_change = []
    init(value || max, min, max)
  end
  
  def on_change(&block)
    @on_change << block
  end
  
  def v=(new_value)
    old_value = @v
    @v = new_value.clamp(@min, @max)
    
    if @v != old_value
      @on_change.each { |callback| callback.call(self, old_value, @v) }
    end
    
    @v
  end
  
  def to_s
    "#{@v}/#{@max}"
  end
  
  def to_f
    @v.to_f
  end
  
  def to_i
    @v.to_i
  end
  
  def empty?
    @v <= @min
  end
  
  def full?
    @v >= @max
  end
  
  def +(other)
    self.v += other
  end
  
  def -(other)
    self.v -= other
  end
end
```

This enhanced version adds:
- Change callbacks
- Better type conversion
- Convenience methods
- Clamping values when set
- More intuitive operator overloading

Use it like this:

```ruby
health = GameStat.new(0, 100)
health.on_change do |stat, old_val, new_val|
  puts "Health changed from #{old_val} to #{new_val}"
  
  if stat.empty?
    puts "Critical health!"
  end
end

health -= 25  # Fires callback
health += 50  # Fires callback
```

This documentation covers the core functionality of the `Hoard::Stat` class and provides practical examples of how to use it in your game.
