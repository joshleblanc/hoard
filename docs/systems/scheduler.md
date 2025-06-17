# Scheduler System

The Scheduler system in Hoard provides a way to schedule and manage delayed or repeated code execution, making it ideal for timing-based game mechanics, animations, and sequenced events.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [API Reference](#api-reference)
4. [Examples](#examples)
   - [Delayed Execution](#delayed-execution)
   - [Sequenced Events](#sequenced-events)
   - [Repeating Actions](#repeating-actions)
5. [Best Practices](#best-practices)

## Overview

The Scheduler system allows you to:
- Execute code after a delay
- Create sequences of timed events
- Manage multiple scheduled tasks
- Chain actions with different delays

## Basic Usage

```ruby
# Schedule a task to run after 60 frames (1 second at 60 FPS)
Hoard::Scheduler.schedule(60) do |s|
  puts "This runs after 1 second"
  
  # Schedule another task after this one completes
  s.wait(30) do
    puts "This runs 0.5 seconds after the first message"
  end
end

# In your game's update method
Hoard::Scheduler.tick
```

## API Reference

### Class Methods

#### `Scheduler.schedule(frames = 0, &block)`
Schedules a new task to run after the specified number of frames.

- `frames`: Number of frames to wait before executing the block
- `block`: The code to execute (receives the scheduler instance as a parameter)

#### `Scheduler.tick`
Updates all scheduled tasks. Should be called once per frame in your game's update loop.

### Instance Methods

#### `wait(frames = 1, &block)`
Adds a delay within a scheduled task.

- `frames`: Number of frames to wait
- `block`: Optional block to execute after the wait

#### `ready?`
Returns `true` if the task is ready to execute.

#### `run?`
Returns `true` if the task has started running.

#### `done?`
Returns `true` if the task has completed.

## Examples

### Delayed Execution

```ruby
# Show a message after 2 seconds
def show_delayed_message
  Hoard::Scheduler.schedule(120) do
    $game.hud.show_message("Important message!")
  end
end
```

### Sequenced Events

```ruby
# Create a sequence of events
def play_cutscene
  Hoard::Scheduler.schedule do |s|
    # Show first message immediately
    $game.hud.show_message("The door creaks open...")
    
    # Wait 1 second
    s.wait(60) do
      $game.hud.show_message("A cold breeze flows through the doorway.")
    end
    
    # Wait another second
    s.wait(60) do
      $game.hud.show_message("You step forward into the darkness...")
      start_level_transition
    end
  end
end
```

### Repeating Actions

```ruby
# Create a repeating effect
def start_heartbeat_effect
  Hoard::Scheduler.schedule do |s|
    # Pulsate the screen red
    $game.screen.flash(0xff0000, 10)
    
    # Schedule the next pulse in 2 seconds
    s.wait(120) do
      start_heartbeat_effect
    end
  end
end

# Stop the effect by setting a flag
@stop_heartbeat = false

def start_heartbeat_effect
  return if @stop_heartbeat
  
  Hoard::Scheduler.schedule do |s|
    $game.screen.flash(0xff0000, 10)
    
    s.wait(120) do
      start_heartbeat_effect
    end
  end
end
```

## Best Practices

1. **Centralized Updates**: Always call `Scheduler.tick` in your main game loop
2. **Clean Up**: Be mindful of creating infinite loops with repeating tasks
3. **Use Variables**: Store scheduler instances if you need to cancel them later
4. **Keep It Simple**: Break complex sequences into smaller, named methods
5. **Error Handling**: Wrap scheduled code in begin/rescue blocks to prevent crashes
6. **Performance**: Avoid scheduling many short-lived tasks when one would suffice

### Advanced Usage

#### Chaining with Different Delays

```ruby
def play_sequence
  schedule = Hoard::Scheduler.schedule do |s|
    # First action
    puts "Action 1"
    
    # Wait 1 second
    s.wait(60) do
      puts "Action 2 after 1 second"
    end
    
    # This runs immediately after the wait is scheduled (not after it completes)
    puts "Action 3 (runs immediately after scheduling the wait)"
    
    # To chain actions, nest them in the wait blocks
    s.wait(30) do
      puts "Action 4 after 0.5 seconds"
      
      s.wait(30) do
        puts "Action 5 after another 0.5 seconds"
      end
    end
  end
  
  # Store the scheduler instance if you need to cancel it later
  @current_sequence = schedule
end
```

#### Canceling Scheduled Tasks

```ruby
# Store the scheduler instance when creating it
@enemy_ai = Hoard::Scheduler.schedule(30) do |s|
  # AI logic here
  
  # Schedule next AI update
  @enemy_ai = s.wait(30) do
    # Next update
  end
end

# Later, to cancel the AI updates
if @enemy_ai
  @enemy_ai = nil  # Remove reference
  # The scheduler will be garbage collected
end
```

#### Using with Game Objects

```ruby
class Enemy < Hoard::Entity
  def initialize
    super
    @ai_schedule = nil
    start_ai
  end
  
  def start_ai
    @ai_schedule = Hoard::Scheduler.schedule(rand(60)) do |s|
      # Make a decision
      case rand(3)
      when 0 then move_randomly
      when 1 then attack_player
      when 2 then idle
      end
      
      # Schedule next decision
      @ai_schedule = s.wait(30 + rand(60)) { start_ai }
    end
  end
  
  def on_removed
    super
    # Clean up scheduler when enemy is removed
    @ai_schedule = nil
  end
end
```

This documentation covers the core functionality of the Scheduler system. For more advanced usage patterns, refer to the source code and experiment with different scheduling strategies.
