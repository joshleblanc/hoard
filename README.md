# Hoard

A DragonRuby port of [deepnight's gameBase](https://github.com/deepnight/gameBase), a powerful 2D game framework built on top of DragonRuby GTK.

## Overview

Hoard is a feature-rich 2D game framework that provides:

- **Entity-Component System**: Flexible entity management with scriptable components
- **Physics**: Built-in physics with velocity, collisions, and forces
- **UI Framework**: Complete UI toolkit for building game interfaces
- **Animation System**: Sprite and tween animations
- **Scripting**: Extensible script system for game logic
- **Level Design**: LDtk integration for level design
- **Particle Effects**: Built-in particle system

## Core Components

### 1. Process System

The foundation of Hoard's architecture. Manages the game loop and object hierarchy.

- [Process](docs/process.md): Base class for all game objects
- [Entity](docs/entity.md): Game objects with position, size, and components
- [Game](docs/game.md): Main game class that manages the game state

### 2. Physics

- [Velocity](docs/physics/velocity.md): Handles movement and forces
- [Collisions](docs/physics/collisions.md): Collision detection and response

### 3. UI System

- [Element](docs/ui/element.md): Base UI element
- [Window](docs/ui/window.md): Container for UI elements
- [Button](docs/ui/button.md): Interactive button element
- [Text](docs/ui/text.md): Text rendering
- [Layouts](docs/ui/layouts.md): Row and column layouts

### 4. Scripting

- [Script](docs/script.md): Base class for game logic scripts
- [Scriptable](docs/scriptable.md): Mixin for scriptable objects
- [Built-in Scripts](docs/scripts/README.md): Collection of common game scripts

### 5. Level Design (LDtk)


- [World](docs/ldtk/world.md): LDtk world loader
- [Level](docs/ldtk/level.md): Individual level data
- [Entities](docs/ldtk/entities.md): LDtk entity support

## Getting Started

### Installation

1. Clone this repository into your DragonRuby project
2. Require the library in your main file:

```ruby
require 'app/hoard'
```

### Basic Example

```ruby
# main.rb
class MyGame < Hoard::Game
  def initialize
    super
    # Your game initialization code here
  end
  
  def update
    # Your game loop logic here
  end
  
  def render
    # Your rendering code here
  end
end

def tick(args)
  $game ||= MyGame.new
  $game.tick
end
```

## Documentation

For detailed documentation, see the [docs](docs/) directory.

## License

MIT License - See [LICENSE](LICENSE) for details.