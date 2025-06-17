# Process Class

The `Process` class is the foundation of Hoard's architecture, providing a hierarchical structure for game objects and managing the game loop.

## Overview

`Process` is the base class for all game objects in Hoard. It provides:
- Hierarchical object management (parent/child relationships)
- Game loop integration (pre_update, update, post_update)
- Time management and cooldowns
- Cleanup and destruction

## Key Features

### Lifecycle Methods

- `initialize(parent = nil)`: Constructor, optionally takes a parent process
- `pre_update`: Called before the main update loop
- `update`: Main update logic
- `post_update`: Called after the main update loop
- `shutdown`: Cleanup resources when the process is destroyed

### Time Management

- `tmod`: Scaled time multiplier for frame-rate independent movement
- `utmod`: Unscaled time multiplier
- `ftime`: Total frames since start
- `uftime`: Total unscaled frames since start

### Hierarchy Management

- `add_child(child)`: Add a child process
- `remove_child(child)`: Remove a child process
- `destroy`: Mark the process for destruction
- `destroyed?`: Check if the process is marked for destruction

## Example Usage

### Basic Process

```ruby
class MyProcess < Hoard::Process
  def initialize(parent = nil)
    super(parent)  # Important: always call super
    @counter = 0
    @position = { x: 0, y: 0 }
    @speed = 2
  end
  
  def update
    # This runs every frame
    @counter += 1
    @position[:x] += @speed * tmod  # Use tmod for frame-rate independence
    
    # Destroy after 100 updates
    destroy if @counter >= 100
  end
  
  def render
    # Draw something at the current position
    args.outputs.solids << {
      x: @position[:x], y: @position[:y],
      w: 32, h: 32,
      r: 255, g: 0, b: 0
    }
  end
  
  def on_remove
    # Cleanup resources here
    puts "Process removed after #{@counter} updates"
  end
end

# Create and add to game
process = MyProcess.new
game.add_child(process)
```

### Parent-Child Relationship

```ruby
class ParentProcess < Hoard::Process
  def initialize
    super
    @children = []
    
    # Create child processes
    3.times do |i|
      child = ChildProcess.new(self)  # Pass self as parent
      @children << child
      add_child(child)
    end
  end
  
  def update
    # Children are automatically updated
    puts "Parent updating with #{@children.size} children"
  end
  
  def remove_child_by_index(index)
    if child = @children[index]
      child.destroy
      @children.delete_at(index)
    end
  end
end

class ChildProcess < Hoard::Process
  def initialize(parent)
    super(parent)  # Important: pass parent to super
    @lifetime = 60 + rand(60)  # Random lifetime
  end
  
  def update
    @lifetime -= 1
    destroy if @lifetime <= 0
  end
  
  def on_remove
    puts "Child process removed after #{60 - @lifetime} frames"
  end
end
```

### Using Time Management

```ruby
class TimedProcess < Hoard::Process
  def initialize
    super
    @start_time = Time.now
    @elapsed = 0
    @interval = 1.0  # seconds
    @timer = 0
  end
  
  def update
    # ftime is total frames since start
    @elapsed = ftime / 60.0  # Convert to seconds
    
    # tmod is scaled by game speed (affected by slow motion)
    @timer += tmod / 60.0  # Increment timer based on scaled time
    
    # utmod is not affected by game speed
    @real_elapsed = uftime / 60.0  # Real time elapsed
    
    if @timer >= @interval
      puts "Timer fired! Game time: #{@elapsed.round(2)}s, " \
           "Real time: #{@real_elapsed.round(2)}s"
      @timer = 0
    end
  end
end
```

### Process with Cooldowns

```ruby
class CooldownProcess < Hoard::Process
  def initialize
    super
    @cooldown = 0
    @can_act = true
  end
  
  def update
    # Update cooldown
    if @cooldown > 0
      @cooldown -= tmod / 60.0
      @can_act = false
    else
      @can_act = true
    end
    
    # Example action with cooldown
    if args.inputs.keyboard.key_down.space && @can_act
      perform_action
      @cooldown = 1.0  # 1 second cooldown
    end
  end
  
  def perform_action
    puts "Action performed!"
    # Action logic here
  end
end
```

## Advanced Usage

### Process Pools

```ruby
class ProcessPool < Hoard::Process
  def initialize(max_processes = 10)
    super
    @max_processes = max_processes
    @processes = []
  end
  
  def add_process(process_class, *args)
    if @processes.size < @max_processes
      process = process_class.new(self, *args)
      @processes << process
      add_child(process)
      process
    end
  end
  
  def update
    # Clean up destroyed processes
    @processes.reject! do |process|
      if process.destroyed?
        remove_child(process)
        true
      end
    end
  end
  
  def full?
    @processes.size >= @max_processes
  end
end

# Usage
pool = ProcessPool.new(5)

def spawn_enemy
  return if pool.full?
  
  pool.add_process(Enemy, x: rand(1280), y: rand(720))
end

# In your game loop
if args.tick_count % 60 == 0  # Every second
  spawn_enemy
end
```

### State Machine

```ruby
class StateMachine < Hoard::Process
  def initialize(initial_state)
    super
    @states = {}
    @current_state = nil
    transition_to(initial_state) if initial_state
  end
  
  def add_state(name, state_class)
    @states[name] = state_class.new(self)
  end
  
  def transition_to(state_name)
    @current_state&.on_exit
    @current_state = @states[state_name]
    @current_state.on_enter
  end
  
  def update
    @current_state&.update
  end
  
  def render
    @current_state&.render
  end
end

# Example state
class IdleState
  def initialize(machine)
    @machine = machine
    @timer = 0
  end
  
  def on_enter
    puts "Entering Idle state"
    @timer = 0
  end
  
  def update
    @timer += 1
    if @timer > 60  # After 1 second
      @machine.transition_to(:active)
    end
  end
  
  def on_exit
    puts "Exiting Idle state"
  end
end

# Usage
machine = StateMachine.new(:idle)
machine.add_state(:idle, IdleState)
machine.add_state(:active, ActiveState)
```

## Best Practices

1. **Always call super**: When overriding lifecycle methods, always call `super` unless you have a good reason not to.

2. **Use destroy for cleanup**: Instead of directly removing objects, call `destroy` and let the process hierarchy handle cleanup.

3. **Leverage the hierarchy**: Use parent-child relationships to group related processes and manage their lifetimes together.

4. **Be mindful of performance**: Keep `update` methods efficient, especially for processes with many children.

5. **Use tmod for movement**: Always multiply movement and animations by `tmod` for frame-rate independence.

6. **Clean up resources**: Implement `on_remove` to clean up any resources your process uses.

7. **Avoid deep hierarchies**: While the process system supports deep nesting, very deep hierarchies can impact performance.

8. **Use process pools**: For frequently created/destroyed objects, consider using a process pool to avoid allocation overhead.
    @counter += 1
    puts "Counter: #{@counter}"
    
    # Destroy after 100 updates
    destroy if @counter >= 100
  end
end

# In your game:
process = MyProcess.new
```

## Class Methods

- `find(what, root = ROOTS)`: Find a process by type
- `update_all(utmod)`: Update all root processes
- `shutdown`: Shutdown all processes
- `broadcast_to_scripts(method_name, *args, &blk)`: Send a message to all scripts

## Best Practices

1. Always call `super` in overridden lifecycle methods
2. Use `destroy` instead of direct object deletion
3. Keep update logic in `update` method
4. Use `pre_update` for setup that needs to happen before other updates
5. Use `post_update` for cleanup that needs to happen after all updates
