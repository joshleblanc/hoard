# Game Class

The `Game` class is the main entry point for Hoard applications, managing the game loop, rendering, and global state.

## Overview

The `Game` class extends `Process` and provides:
- Main game loop management
- Camera control
- Slow-motion effects
- Global game state
- Level management

## Key Features

### Game Loop
- `tick`: Main game loop method called every frame
- `pre_update`: Called before the main update
- `update`: Main update logic
- `post_update`: Called after the main update
- `render`: Handles rendering of the game

### Camera Control
- `camera`: The main camera instance
- `center_on_target`: Center camera on target entity
- `shake_s`: Apply screen shake effect

### Time Control
- `add_slowmo`: Add a slow-motion effect
- `update_slow_mos`: Update active slow-motion effects
- `cur_game_speed`: Current game speed multiplier

## Example Usage

```ruby
class MyGame < Hoard::Game
  def initialize
    super
    @player = Player.new(10, 10)
    add_child(@player)
    
    # Center camera on player
    camera.target = @player
    
    # Add some slow motion for effect
    add_slowmo(:intro, 2.0, 0.5)
  end
  
  def update
    # Game logic here
  end
  
  def render
    super  # Renders all children
    
    # Additional rendering (HUD, etc.)
    args.outputs.labels << {
      x: 10, y: 700, text: "FPS: #{args.gtk.current_framerate.to_i}",
      size_enum: 4, r: 255, g: 255, b: 255
    }
  end
end

# In main.rb
def tick(args)
  $game ||= MyGame.new
  $game.tick
end
```

## Level Management

```ruby
def load_level(level_name)
  # Unload current level if exists
  @current_level.destroy if @current_level
  
  # Load new level
  @current_level = Level.new(level_name)
  add_child(@current_level)
  
  # Position player at level start
  if spawn_point = @current_level.find_entity(:player_spawn)
    @player.set_pos_case(spawn_point.x, spawn_point.y)
  end
  
  # Reset camera
  camera.center_on_target
end
```

## Best Practices

1. **Singleton Pattern**: Create a single instance of your Game class
2. **Separation of Concerns**: Keep game logic in separate components/scripts
3. **Camera Management**: Use the camera system for screen effects and following
4. **Slow Motion**: Use `add_slowmo` for dramatic effects
5. **Cleanup**: Properly clean up resources when changing levels

## Integration with DragonRuby

Hoard is designed to work with DragonRuby's `tick` method. The simplest integration is:

```ruby
def tick(args)
  # Initialize game if not already done
  $game ||= MyGame.new
  
  # Update game state
  $game.tick
  
  # Optional: Handle input globally
  if args.inputs.keyboard.key_down.escape
    $gtk.request_quit
  end
end
```

## Advanced Features

### Multiple Views
```ruby
def render
  # Main game view
  args.outputs[:scene].sprites << @game_layer
  
  # UI overlay
  args.outputs[:ui].labels << { x: 10, y: 700, text: "Score: #{@score}" }
  
  # Combine all layers
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :scene }
  args.outputs.sprites << { x: 0, y: 0, w: 1280, h: 720, path: :ui }
end
```

### Global Events
```rubn
def broadcast_event(event_name, *args)
  # Send to all entities
  Process.broadcast_to_scripts(:on_event, event_name, *args)
end

# In any script or entity:
def on_event(event_name, *args)
  case event_name
  when :player_died
    # Handle player death
  when :level_complete
    # Handle level completion
  end
end
```
