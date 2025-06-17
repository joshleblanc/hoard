# User System

The `Hoard::User` class is a core component that manages player data and their associated in-game representation. It serves as a bridge between player accounts and their in-game characters.

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [API Reference](#api-reference)
4. [Examples](#examples)
   - [Creating a User](#creating-a-user)
   - [Player Spawning](#player-spawning)
   - [Player Management](#player-management)
5. [Best Practices](#best-practices)

## Overview

The `Hoard::User` class extends `Hoard::Entity` and provides:
- User account management
- Player character spawning/despawning
- Camera association
- Player state tracking

## Basic Usage

```ruby
# Create a new user
@user = Hoard::User.new("player1", "avatar_warrior")

# Spawn a player character
@player_class = Game::Player  # Your custom player class
@user.spawn_player(@player_class) do |player|
  # Customize the player
  player.health = 100
  player.position = { x: 100, y: 100 }
end

# In your game loop
def tick
  # Update user's player if it exists
  @user.player.update if @user.player
  
  # Render the player
  @user.player.render if @user.player
end
```

## API Reference

### Initialization

```ruby
def initialize(username, player_card_icon = nil)
  @username = username
  @player_card_icon = player_card_icon
  @player = nil
  @camera = nil
  super()
end
```

### Properties

- `username`: The user's display name (String)
- `player_card_icon`: An icon or avatar identifier for the user (String/Symbol)
- `player`: The currently spawned player entity (can be nil)
- `camera`: The camera associated with this user (can be nil)

### Methods

#### `spawn_player(player_template, position = nil, rotation = nil, &block)`
Spawns a new player character.

- `player_template`: The class to use for creating the player
- `position`: Optional starting position (Hash with :x and :y)
- `rotation`: Optional starting rotation
- `block`: Optional block that receives the new player for customization

#### `despawn_player(&block)`
Removes the current player character.

- `block`: Optional block to execute after despawning

## Examples

### Creating a User

```ruby
# Basic user creation
@user = Hoard::User.new("Player1", :warrior_icon)

# With a camera
@user.camera = Hoard::Camera.new

# Access user properties
puts "Welcome, #{@user.username}!"
```

### Player Spawning

```ruby
# Define a custom player class
class Game::Player < Hoard::Entity
  attr_accessor :health, :max_health
  
  def initialize(**opts)
    super
    @health = 100
    @max_health = 100
    @speed = 5
  end
  
  def update
    # Handle input and update position
    if $args.inputs.keyboard.key_held.left
      self.x -= @speed
    elsif $args.inputs.keyboard.key_held.right
      self.x += @speed
    end
    
    # Keep player in bounds
    self.x = self.x.clamp(0, 1280 - 32)
    self.y = self.y.clamp(0, 720 - 32)
  end
  
  def render
    $args.outputs.sprites << {
      x: x, y: y, w: 32, h: 32,
      path: 'sprites/player.png',
      angle: rotation || 0
    }
  end
end

# Spawn the player
@user.spawn_player(Game::Player, { x: 100, y: 100 }) do |player|
  player.health = 150
  player.max_health = 150
  player.rotation = 45
end
```

### Player Management

```ruby
class Game < Hoard::Game
  def initialize
    super
    @user = Hoard::User.new("Player1", :default_icon)
    @user.camera = Hoard::Camera.new
    
    # Load player class
    @player_class = Game::Player
    
    # Spawn player at start
    spawn_player
  end
  
  def spawn_player
    @user.spawn_player(@player_class, { x: 640, y: 360 }) do |player|
      player.health = 100
      # Customize player appearance
      player.sprite_path = 'sprites/player_warrior.png'
    end
    
    # Position camera on player
    if @user.camera && @user.player
      @user.camera.follow(@user.player)
    end
  end
  
  def despawn_player
    @user.despawn_player do
      # Show death animation
      show_death_effect(@user.player.position)
    end
  end
  
  def update
    super
    
    # Respawn player if dead and pressing a button
    if !@user.player && $args.inputs.keyboard.key_down.space
      spawn_player
    end
  end
  
  def render
    super
    
    # Render player if exists
    @user.player&.render
    
    # Render UI
    render_ui
  end
  
  def render_ui
    # Show respawn prompt if player is dead
    unless @user.player
      $args.outputs.labels << {
        x: 640, y: 360, text: "Press SPACE to respawn",
        alignment_enum: 1, size_enum: 10
      }
    end
  end
end
```

## Best Practices

1. **Separation of Concerns**: Keep player logic in the Player class, not in the User class
2. **Camera Management**: Associate cameras with users for split-screen multiplayer
3. **Player State**: Use the User class to persist data between player respawns
4. **Input Handling**: Consider using an input manager that routes controls to the current player
5. **Serialization**: Save/load user data including preferences and progress

### Multiplayer Considerations

```ruby
class Game < Hoard::Game
  def initialize
    super
    @users = []
    
    # Local player
    add_user("Player1", :warrior_icon)
    
    # Network players
    # (In a real game, these would come from the network)
    @network_players = [
      { username: "Player2", icon: :mage_icon, x: 100, y: 100 },
      { username: "Player3", icon: :archer_icon, x: 1180, y: 100 }
    ]
    
    # Setup network callbacks
    setup_network_callbacks
  end
  
  def add_user(username, icon)
    user = Hoard::User.new(username, icon)
    user.camera = Hoard::Camera.new
    
    # Position camera for split-screen
    position_camera(user, @users.size)
    
    @users << user
    
    # Spawn player for this user
    spawn_player(user)
    
    user
  end
  
  def spawn_player(user, position = nil)
    position ||= { x: 640, y: 360 }
    
    user.spawn_player(Player, position) do |player|
      player.health = 100
      player.max_health = 100
      player.team = :blue  # Or determine team based on user
    end
    
    # Update camera to follow this player
    user.camera.follow(user.player) if user.camera
  end
  
  def position_camera(user, index)
    return unless user.camera
    
    case @users.size
    when 1  # Full screen
      user.camera.viewport = { x: 0, y: 0, w: 1280, h: 720 }
    when 2  # Split horizontally
      user.camera.viewport = {
        x: index * 640, y: 0,
        w: 640, h: 720
      }
    when 3..4  # 2x2 grid
      row = index / 2
      col = index % 2
      user.camera.viewport = {
        x: col * 640, y: row * 360,
        w: 640, h: 360
      }
    end
  end
  
  def update
    super
    
    # Update all users' players
    @users.each do |user|
      user.player.update if user.player
      user.camera.update if user.camera
    end
  end
  
  def render
    super
    
    # Render each user's view
    @users.each do |user|
      next unless user.camera
      
      # Set up viewport for this user
      viewport = user.camera.viewport
      $args.outputs[:viewport] = viewport
      
      # Render game world from this user's perspective
      render_world(user.camera)
      
      # Render UI for this user
      render_ui(user)
    end
    
    # Reset to full screen for any global rendering
    $args.outputs[:viewport] = { x: 0, y: 0, w: 1280, h: 720 }
  end
  
  def render_world(camera)
    # Render game world with camera transform
    # (Implementation depends on your rendering system)
  end
  
  def render_ui(user)
    # Render user-specific UI
    if user.player
      render_health_bar(user.player)
    end
  end
  
  def setup_network_callbacks
    # Example: Handle player join
    # @network.on(:player_join) do |player_data|
    #   add_user(player_data[:username], player_data[:icon])
    # end
    # 
    # # Handle player leave
    # @network.on(:player_leave) do |username|
    #   user = @users.find { |u| u.username == username }
    #   user&.despawn_player
    #   @users.delete(user)
    # end
  end
end
```

### Common Patterns

1. **Player Persistence**:
   ```ruby
   # Save player progress
   def save_game
     data = {
       username: @user.username,
       position: @user.player.position,
       stats: @user.player.stats,
       inventory: @user.player.inventory
     }
     
     File.write('save.json', data.to_json)
   end
   
   # Load player progress
   def load_game
     return unless File.exist?('save.json')
     
     data = JSON.parse(File.read('save.json'))
     @user.spawn_player(Player, data['position']) do |player|
       player.stats = data['stats']
       player.inventory = data['inventory']
     end
   end
   ```

2. **Player Customization**:
   ```ruby
   class CharacterCustomizer
     def initialize(user)
       @user = user
       @options = {
         hair: [:short, :long, :mohawk],
         armor: [:leather, :chain, :plate],
         weapon: [:sword, :axe, :staff]
       }
       @selections = {}
     end
     
     def apply_to_player
       return unless @user.player
       
       # Update player's appearance based on selections
       @user.player.appearance = @selections.dup
       
       # Update sprite path
       @user.player.sprite_path = "characters/#{@user.username}_#{@selections.values.join('_')}.png"
     end
   end
   ```

3. **Player Input Handling**:
   ```ruby
   class InputHandler
     def initialize(user)
       @user = user
       @key_bindings = {
         move_left: :left,
         move_right: :right,
         jump: :space,
         attack: :z,
         special: :x
       }
     end
     
     def update
       return unless @user.player
       
       player = @user.player
       
       # Handle movement
       if $args.inputs.keyboard.key_held(@key_bindings[:move_left])
         player.move(-1, 0)
       elsif $args.inputs.keyboard.key_held(@key_bindings[:move_right])
         player.move(1, 0)
       end
       
       # Handle actions
       if $args.inputs.keyboard.key_down(@key_bindings[:jump])
         player.jump
       end
       
       if $args.inputs.keyboard.key_down(@key_bindings[:attack])
         player.attack
       end
     end
   end
   ```

This documentation covers the core functionality of the `Hoard::User` class and provides practical examples of how to use it in your game, including single-player and multiplayer scenarios.
