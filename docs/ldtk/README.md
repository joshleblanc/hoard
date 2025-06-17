# LDtk Integration

The `ldtk` module provides seamless integration with the [LDtk level editor](https://ldtk.io/), allowing you to design levels in LDtk and load them into your Hoard game.

## Table of Contents

1. [Overview](#overview)
2. [Loading LDtk Levels](#loading-ldtk-levels)
3. [Working with Levels](#working-with-levels)
4. [Entities](#entities)
5. [Custom Fields](#custom-fields)
6. [Best Practices](#best-practices)
7. [API Reference](#api-reference)

## Overview

Hoard's LDtk integration provides:
- Loading of LDtk project files (`.ldtk`)
- Access to levels, layers, and entities
- Support for custom fields and enums
- Entity spawning with custom components

## Loading LDtk Levels

### Basic Loading

```ruby
# Load an LDtk project
ldtk_project = Hoard::Ldtk::Root.import_from_file("path/to/levels.ldtk")

# Get a level by name
grasslands = ldtk_project.level(identifier: "Grasslands")

# Or by UID
tutorial = ldtk_project.level(uid: 1)

# Or by index
first_level = ldtk_project.levels.first
```

### World Layouts

LDtk supports different world layouts:

```ruby
# Check the world layout
if ldtk_project.grid_vania?
  # Connected world with grid-based coordinates
elsif ldtk_project.linear_horizontal?
  # Linear left-to-right progression
elsif ldtk_project.linear_vertical?
  # Linear bottom-to-top progression
elsif ldtk_project.free?
  # Free-form layout
end
```

## Working with Levels

### Accessing Level Data

```ruby
# Get level dimensions in pixels
width = level.px_wid
height = level.px_hei

# Get background color
bg_color = level.bg_color  # Returns [r, g, b] array

# Get level position in world (for world layouts)
world_x = level.world_x
world_y = level.world_y
```

### Accessing Layers

```ruby
# Get all layers
layers = level.layer_instances

# Find a layer by name
collision_layer = level.layer_instances.find { |l| l.identifier == "Collisions" }

# Get layer data
if collision_layer
  # For Tile layers
  if collision_layer.type == :Tiles
    grid_size = collision_layer.grid_size
    tiles = collision_layer.grid_tiles
    
    # Access a specific tile
    tile = tiles[0][0]  # First row, first column
    if tile
      tile_id = tile.tile_id
      flip_x = tile.flip_x?
      flip_y = tile.flip_y?
    end
  
  # For Entity layers
  elsif collision_layer.type == :Entities
    entities = collision_layer.entity_instances
  end
end
```

## Entities

### Accessing Entities

```ruby
# Get all entities in a level
entities = level.layer_instances.flat_map(&:entity_instances)

# Find entities by type
players = entities.select { |e| e.identifier == "Player" }
enemies = entities.select { |e| e.identifier == "Enemy" }

# Access entity properties
player = players.first
if player
  # Position in pixels
  x = player.px[0]
  y = player.px[1]
  
  # Size in pixels
  width = player.width
  height = player.height
  
  # Custom fields (see below)
  health = player.field_instances["health"]
end
```

### Spawning Game Entities

```ruby
# In your game's level loading code
def spawn_entities_from_ldtk(level)
  level.layer_instances.each do |layer|
    next unless layer.type == :Entities
    
    layer.entity_instances.each do |entity_def|
      case entity_def.identifier
      when "Player"
        spawn_player(entity_def)
      when "Enemy"
        spawn_enemy(entity_def)
      when "Item"
        spawn_item(entity_def)
      end
    end
  end
end

def spawn_player(entity_def)
  x, y = entity_def.px
  player = Player.new(x, y)
  
  # Apply custom fields
  if health = entity_def.field_instances["health"]
    player.health = health
  end
  
  add_entity(player)
  player
end
```

## Custom Fields

LDtk allows defining custom fields on entities. These are accessible through the `field_instances` hash.

### Defining Custom Fields in LDtk

1. In LDtk, select an entity definition
2. Add a custom field with a name and type (Int, Float, String, etc.)
3. Set values for instances of that entity

### Accessing Custom Fields

```ruby
entity_def.field_instances.each do |field_name, value|
  puts "#{field_name}: #{value}"
end

# Get a specific field
if damage = entity_def.field_instances["damage"]
  # Use the damage value
end

# For enum fields
if enemy_type = entity_def.field_instances["enemy_type"]
  case enemy_type
  when "Flying"
    # Handle flying enemy
  when "Ground"
    # Handle ground enemy
  end
end
```

## Best Practices

1. **Entity Factories**: Create factory methods for spawning different entity types
2. **Custom Field Conventions**: Establish naming conventions for custom fields
3. **Layer Organization**: Use consistent layer naming in LDtk
4. **Prefabs**: Create reusable entity prefabs in LDtk
5. **Performance**: Only load necessary levels in memory

## API Reference

### Root (`Hoard::Ldtk::Root`)

- `levels`: Array of all levels
- `defs`: Definitions (entities, enums, tilesets)
- `worlds`: World definitions (if using worlds)
- `grid_vania?`: Check if using GridVania layout
- `linear_horizontal?`: Check if using LinearHorizontal layout
- `linear_vertical?`: Check if using LinearVertical layout
- `free?`: Check if using Free layout
- `level(**query)`: Find a level by attributes
- `enum(id)`: Get an enum definition by ID
- `tileset(uid)`: Get a tileset by UID
- `entity(uid)`: Get an entity definition by UID

### Level (`Hoard::Ldtk::Level`)

- `identifier`: Level name
- `uid`: Unique ID
- `world_x`, `world_y`: Position in world (for world layouts)
- `px_wid`, `px_hei`: Dimensions in pixels
- `bg_color`: Background color [r, g, b]
- `layer_instances`: Array of layer instances
- `neighbors`: Connected levels (for world layouts)

### LayerInstance (`Hoor::Ldtk::LayerInstance`)

- `identifier`: Layer name
- `type`: `:IntGrid`, `:Entities`, `:Tiles`, or `:AutoLayer`
- `grid_size`: Size of grid cells
- `grid_tiles`: 2D array of tiles (for Tiles layers)
- `entity_instances`: Array of entities (for Entities layers)
- `int_grid`: 2D array of integers (for IntGrid layers)

### EntityInstance (`Hoard::Ldtk::EntityInstance`)

- `identifier`: Entity type name
- `iid`: Instance ID
- `px`: [x, y] position in pixels
- `width`, `height`: Dimensions in pixels
- `field_instances`: Hash of custom field values
- `tile`: Tile information if entity uses a tile

### EntityDefinition (`Hoor::Ldtk::EntityDefinition`)

- `identifier`: Entity type name
- `uid`: Unique ID
- `width`, `height`: Default dimensions
- `color`: Display color
- `field_defs`: Array of field definitions

### Field Definitions

- `identifier`: Field name
- `type`: Field type (`Int`, `Float`, `String`, etc.)
- `is_array`: Whether the field is an array
- `default_value`: Default value
- `accepts_types`: For entity/enum references

## Example: Complete Level Loading

```ruby
class Game < Hoard::Game
  def load_level(level_name)
    # Unload current level
    @current_level_entities&.each(&:destroy)
    @current_level_entities = []
    
    # Load LDtk level
    @ldtk_level = @ldtk_project.level(identifier: level_name)
    
    # Set up level bounds
    @level_width = @ldtk_level.px_wid
    @level_height = @ldtk_level.px_hei
    
    # Process layers
    @ldtk_level.layer_instances.each do |layer|
      case layer.type
      when :Tiles
        process_tile_layer(layer)
      when :Entities
        process_entity_layer(layer)
      end
    end
    
    # Position camera
    if @player
      @camera.target = @player
      @camera.zoom_to_fit(@level_width, @level_height)
    end
  end
  
  def process_entity_layer(layer)
    layer.entity_instances.each do |entity_def|
      entity = case entity_def.identifier
               when "Player" then spawn_player(entity_def)
               when "Enemy" then spawn_enemy(entity_def)
               when "Item" then spawn_item(entity_def)
               end
      
      @current_level_entities << entity if entity
    end
  end
  
  def spawn_player(entity_def)
    x, y = entity_def.px
    @player = Player.new(x, y)
    
    # Apply custom fields
    if health = entity_def.field_instances["health"]
      @player.health = health
    end
    
    add_entity(@player)
    @player
  end
  
  # ... other spawn methods
end
```

This documentation covers the core functionality of the LDtk integration. For more advanced usage, refer to the LDtk documentation and explore the source code in the `ldtk/` directory.
