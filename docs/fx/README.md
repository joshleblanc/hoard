# FX System

The Hoard FX system provides powerful particle effects and visual feedback for your game. It's built on top of the Process system and integrates with DragonRuby's rendering pipeline.

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
   - [Particles](#particles)
   - [Emitters](#emitters)
   - [Animations](#animations)
3. [Built-in Effects](#built-in-effects)
   - [Dots Explosion](#dots-explosion)
   - [Custom Animations](#custom-animations)
4. [RecyclablePool](#recyclablepool)
   - [Basic Usage](#recyclablepool-basic-usage)
   - [API Reference](#recyclablepool-api)
5. [Best Practices](#best-practices)
6. [Examples](#examples)

## Overview

The FX system in Hoard is designed to be:
- **High-performance**: Uses object pooling for efficient memory management
- **Flexible**: Supports both simple and complex particle effects
- **Integrated**: Works seamlessly with the rest of the Hoard engine
- **Customizable**: Easily create your own effects

## Core Concepts

### Particles

Particles are the basic building blocks of visual effects. Each particle has properties like position, velocity, color, and lifetime.

### Emitters

Emitters create and manage particles. They control when and where particles are spawned and how they behave over time.

### Animations

The FX system supports sprite-based animations for more complex effects.

## Built-in Effects

### Dots Explosion

Create a burst of particles that spread out from a point:

```ruby
# In your game or entity class
def create_explosion(x, y, color = 0xffffff)
  $game.fx.dots_explosion(x, y, color)
end
```

### Custom Animations

Create a simple animation:

```ruby
# In your game or entity class
def create_animation(x, y, path, frames, duration = 30)
  $game.fx.anim(
    x: x,
    y: y,
    w: 32,  # Frame width
    h: 32,  # Frame height
    path: path,
    tile_w: 32,  # Width of each frame in the spritesheet
    tile_h: 32,  # Height of each frame in the spritesheet
    frames: frames,  # Total number of frames
    speed: duration / frames.to_f,  # Frames per second
    loop: false
  )
end
```

## RecyclablePool

The `RecyclablePool` class provides object pooling functionality to improve performance by reusing objects instead of creating and destroying them.

### RecyclablePool Basic Usage

```ruby
# Create a pool of 100 particles
class Particle
  attr_accessor :x, :y, :active
  
  def recycle
    @active = true
    @x = @y = 0
  end
end

pool = Hoard::RecyclablePool.new(100, Particle)

# Get a particle from the pool
particle = pool.alloc
particle.x = 100
particle.y = 200

# When done with the particle
pool.free_element(particle)
```

### RecyclablePool API

- `new(size, klass)` - Create a new pool with the given size and class
- `alloc` - Get a new or recycled object from the pool
- `free_element(element)` - Return an object to the pool
- `free_all` - Return all objects to the pool
- `allocated` - Get the number of currently allocated objects
- `size` - Get the total size of the pool
- `each(&block)` - Iterate over allocated objects
- `find(&block)` - Find an object matching the block condition
- `dispose` - Clean up the pool

## Best Practices

1. **Pool Sizing**: Size your pools appropriately for your game's needs
2. **Recycle Objects**: Always return objects to the pool when done
3. **Batch Updates**: Update particles in batches for better performance
4. **Use Appropriate Blend Modes**: Different effects may require different blend modes
5. **Limit Particle Count**: Be mindful of the number of active particles
6. **Reuse Effects**: Where possible, reuse existing effects instead of creating new ones

## Examples

### Custom Particle System

```ruby
class FireworkEffect < Hoard::Process
  def initialize(x, y, color)
    super()
    @x = x
    @y = y
    @color = color
    @particles = []
    @max_particles = 100
    @pool = Hoard::RecyclablePool.new(@max_particles, Particle)
    
    # Create initial explosion
    create_explosion
  end
  
  def create_explosion
    # Create particles in a circular pattern
    50.times do
      angle = rand * Math::PI * 2
      speed = rand(1.0..3.0)
      
      # Get a particle from the pool
      p = @pool.alloc
      
      # Initialize particle properties
      p.x = @x
      p.y = @y
      p.vx = Math.cos(angle) * speed
      p.vy = Math.sin(angle) * speed
      p.life = 60 + rand(30)  # 1-1.5 seconds at 60 FPS
      p.color = @color
      p.size = 2 + rand(4)
      
      @particles << p
    end
  end
  
  def update
    # Update particles
    @particles.each do |p|
      p.x += p.vx
      p.y += p.vy
      p.vy += 0.1  # Gravity
      p.life -= 1
      
      # Fade out
      p.alpha = (p.life / 90.0 * 255).to_i
      
      # Return to pool when done
      if p.life <= 0
        @pool.free_element(p)
      end
    end
    
    # Remove dead particles
    @particles.reject! { |p| p.life <= 0 }
    
    # Destroy when all particles are gone
    destroy if @particles.empty? && @pool.allocated == 0
  end
  
  def render
    @particles.each do |p|
      $args.outputs.solids << {
        x: p.x - p.size/2, y: p.y - p.size/2,
        w: p.size, h: p.size,
        r: (p.color >> 16) & 0xFF,
        g: (p.color >> 8) & 0xFF,
        b: p.color & 0xFF,
        a: p.alpha
      }
    end
  end
  
  class Particle
    attr_accessor :x, :y, :vx, :vy, :life, :color, :size, :alpha
    
    def recycle
      @x = @y = @vx = @vy = 0
      @life = 0
      @alpha = 255
    end
  end
end
```

### Using the Firework Effect

```ruby
# In your game or entity class
def create_firework(x, y)
  colors = [0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF]
  color = colors.sample
  FireworkEffect.new(x, y, color).add_to_game($game)
end
```

### Particle Emitter

```ruby
class ParticleEmitter < Hoard::Process
  def initialize(x, y, rate: 10, max_particles: 100)
    super()
    @x = x
    @y = y
    @rate = rate  # Particles per second
    @max_particles = max_particles
    @particles = []
    @pool = Hoard::RecyclablePool.new(@max_particles, Particle)
    @timer = 0
  end
  
  def update
    # Emit new particles
    @timer += 1
    if @timer >= 60.0 / @rate
      emit_particle
      @timer = 0
    end
    
    # Update existing particles
    @particles.each do |p|
      p.x += p.vx
      p.y += p.vy
      p.life -= 1
      
      # Apply effects
      p.vy += p.gravity if p.respond_to?(:gravity)
      p.alpha = (p.life / p.max_life.to_f * 255).to_i
      
      # Return to pool when done
      if p.life <= 0
        @pool.free_element(p)
      end
    end
    
    # Remove dead particles
    @particles.reject! { |p| p.life <= 0 }
  end
  
  def emit_particle
    return if @pool.allocated >= @max_particles
    
    p = @pool.alloc
    p.x = @x
    p.y = @y
    angle = rand * Math::PI * 2
    speed = rand(0.5..2.0)
    p.vx = Math.cos(angle) * speed
    p.vy = Math.sin(angle) * speed
    p.life = p.max_life = 60 + rand(60)  # 1-2 seconds at 60 FPS
    p.gravity = -0.05
    p.size = 2 + rand(4)
    p.color = 0xFFFFFF  # White by default
    
    @particles << p
  end
  
  def render
    @particles.each do |p|
      $args.outputs.solids << {
        x: p.x - p.size/2, y: p.y - p.size/2,
        w: p.size, h: p.size,
        r: (p.color >> 16) & 0xFF,
        g: (p.color >> 8) & 0xFF,
        b: p.color & 0xFF,
        a: p.alpha
      }
    end
  end
  
  class Particle
    attr_accessor :x, :y, :vx, :vy, :life, :max_life, :color, :size, :alpha, :gravity
    
    def recycle
      @x = @y = @vx = @vy = 0
      @life = @max_life = 0
      @alpha = 255
      @gravity = 0
    end
  end
end
```

This documentation covers the core concepts of the FX system and RecyclablePool. For more advanced usage, refer to the source code and experiment with different particle effects and animations.
