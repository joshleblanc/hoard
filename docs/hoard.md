# Hoard - Main Module

The `hoard.rb` file serves as the main entry point for the Hoard game library. It's responsible for loading all the necessary components and making them available to your game.

## Table of Contents

1. [Overview](#overview)
2. [Included Components](#included-components)
3. [Basic Usage](#basic-usage)
4. [Module Structure](#module-structure)
5. [Getting Started](#getting-started)
6. [Best Practices](#best-practices)

## Overview

The `hoard.rb` file is the central require point that loads all the components of the Hoard game library. By requiring this single file, you get access to the entire Hoard framework in your DragonRuby project.

## Included Components

Hoard is organized into several key components, all of which are loaded by `hoard.rb`:

### Core Systems
- `Process` - Base class for game objects with update/render lifecycle
- `Entity` - Game entity system with components
- `Game` - Main game class that ties everything together
- `Scriptable` - Mixin for adding scriptable behavior to objects

### UI Framework
- `UI::Element` - Base UI element
- `UI::Window`, `UI::Button`, `UI::Text`, `UI::Image` - UI components
- `UI::Row`, `UI::Col` - Layout components
- `Widget` - Reusable UI widgets

### Gameplay Systems
- `Script` - Base script class
- Various built-in scripts (Gravity, Health, Animation, etc.)
- `Camera` - Viewport and camera management
- `Scheduler` - For timed and sequenced events
- `User` - Player management

### Utilities
- `Cooldown` - For managing cooldowns and timers
- `Delayer` - For delayed execution of code
- `Tweenie` - For animations and transitions
- `LPoint` - For 2D coordinate management
- `Scaler` - For handling screen scaling
- `Const` - Game constants and configuration
- `Utils` - General utility methods

### Physics
- `Velocity` - 2D velocity component
- `VelocityArray` - For managing multiple velocities

### FX
- `FX` - Special effects system
- `RecyclablePool` - Object pooling for performance

## Basic Usage

To use Hoard in your DragonRuby game:

1. Add Hoard to your project (either as a submodule or by copying the files)
2. In your `app/main.rb`, require the Hoard library:

```ruby
# In app/main.rb
require 'app/hoard/hoard'

# Create your game class that inherits from Hoard::Game
class MyGame < Hoard::Game
  def initialize
    super
    # Your initialization code
  end
  
  def tick
    super  # Important: call super to process Hoard systems
    
    # Your game logic
  end
end

# Start the game
$game = MyGame.new

def tick(args)
  $game.tick
end
```

## Module Structure

Hoard follows a modular structure:

```
hoard/
├── hoard.rb                 # Main entry point
├── core/                    # Core systems
│   ├── process.rb
│   ├── entity.rb
│   ├── game.rb
│   └── scriptable.rb
├── ui/                      # UI components
│   ├── element.rb
│   ├── window.rb
│   ├── button.rb
│   └── ...
├── scripts/                 # Built-in scripts
│   ├── gravity_script.rb
│   ├── health_script.rb
│   └── ...
├── widgets/                 # Reusable UI widgets
│   └── ...
└── utils/                   # Utility classes
    ├── cooldown.rb
    ├── delayer.rb
    ├── tweenie.rb
    └── ...
```

## Getting Started

### Creating a Simple Game

1. **Set up your project structure**:
   ```
   my_game/
   ├── app/
   │   ├── main.rb
   │   └── hoard/         # Copy or symlink Hoard files here
   └── mygame.gem
   ```

2. **Create a basic game class**:
   ```ruby
   # app/main.rb
   require 'app/hoard/hoard'
   
   class MyGame < Hoard::Game
     def initialize
       super
       @player = create_player
     end
     
     def create_player
       # Create a player entity
       player = Hoard::Entity.new
       
       # Add components (example)
       player.add_script(Hoard::Scripts::GravityScript.new)
       player.add_script(Hoard::Scripts::PlatformerControls.new)
       
       # Add to the game world
       add_entity(player)
       
       player
     end
     
     def tick
       super  # Process Hoard systems
       
       # Your game logic
       update_player
       render
     end
     
     def update_player
       return unless @player
       # Update player logic
     end
     
     def render
       # Render your game
       if @player
         $args.outputs.sprites << {
           x: @player.x, y: @player.y, w: 32, h: 32,
           path: 'sprites/player.png'
         }
       end
     end
   end
   
   # Start the game
   $game = MyGame.new
   
   def tick(args)
     $game.tick
   end
   ```

## Best Practices

### 1. Game Structure

- Inherit from `Hoard::Game` for your main game class
- Use `super` in your `tick` method to ensure all Hoard systems update
- Organize your code into logical components using the Entity-Component pattern

### 2. Using Entities

- Create entities for game objects
- Add scripts to entities for behavior
- Use the built-in scripts when possible

```ruby
def create_enemy(x, y)
  enemy = Hoard::Entity.new
  
  # Position
  enemy.x = x
  enemy.y = y
  
  # Add physics
  enemy.add_script(Hoard::Scripts::GravityScript.new)
  
  # Add AI behavior
  enemy.add_script(EnemyAIScript.new)
  
  # Add to game
  add_entity(enemy)
  
  enemy
end
```

### 3. UI Development

- Use the built-in UI components for menus and HUD
- Create custom widgets for reusable UI elements
- Use the layout components (`Row`, `Col`) for responsive designs

```ruby
def create_ui
  # Create a window
  window = Hoard::UI::Window.new(
    x: 10, y: 10, 
    w: 200, h: 100,
    title: "Inventory"
  )
  
  # Add content
  window.add_child(
    Hoard::UI::Text.new(text: "Health: 100%")
  )
  
  window
end
```

### 4. Performance Considerations

- Use object pooling for frequently created/destroyed objects
- Be mindful of garbage collection in tight loops
- Use the built-in profiler to identify bottlenecks

### 5. Debugging

- Use the built-in debug rendering
- Add debug overlays for important game state
- Use the console for quick testing

## Advanced Topics

### Custom Scripts

Create custom scripts by inheriting from `Hoard::Script`:

```ruby
class MyCustomScript < Hoard::Script
  def initialize(options = {})
    super
    @cooldown = Hoard::Cooldown.new(30)  # 0.5 seconds at 60 FPS
  end
  
  def update
    return unless @cooldown.ready?
    
    # Your update logic here
    
    @cooldown.reset
  end
  
  def render
    # Optional: Custom rendering
  end
end
```

### Event System

Hoard includes an event system for communication between game objects:

```ruby
# Subscribe to an event
Hoard::Events.subscribe(:player_hit) do |damage, source|
  puts "Player took #{damage} damage from #{source}"
end

# Emit an event
Hoard::Events.emit(:player_hit, 10, :enemy)
```

### Saving and Loading

Use the built-in serialization for saving game state:

```ruby
# Save game
def save_game
  data = {
    player: @player.serialize,
    level: @current_level,
    # ... other game state
  }
  
  $gtk.serialize_state('save.dat', data)
end

# Load game
def load_game
  return unless $gtk.deserialize_state('save.dat')
  
  data = $gtk.deserialize_state('save.dat')
  @player = Hoard::Entity.deserialize(data[:player])
  # ... load other game state
end
```

## Troubleshooting

### Common Issues

1. **Game not updating**: Make sure to call `super` in your `tick` method
2. **Entities not appearing**: Check if you've added them to the game with `add_entity`
3. **Scripts not running**: Ensure you've called `add_script` on the entity
4. **Performance issues**: Check for memory leaks in custom scripts

### Getting Help

- Check the example projects
- Review the API documentation
- Look at the source code for built-in scripts
- Ask for help in the DragonRuby Discord

## Conclusion

The Hoard game library provides a comprehensive set of tools for building 2D games in DragonRuby. By following the patterns and best practices outlined in this documentation, you can create well-structured, maintainable games with less boilerplate code.

For more examples and advanced usage, check out the example projects in the Hoard repository.
