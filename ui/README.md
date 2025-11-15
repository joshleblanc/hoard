# Hoard UI - Simple and Reliable UI System

A clean, predictable UI system for DragonRuby game development. Designed to be simple, explicit, and bug-free.

## Quick Start

```ruby
require_relative 'ui/box.rb'
require_relative 'ui/label.rb'
require_relative 'ui/panel.rb'
require_relative 'ui/button.rb'
require_relative 'ui/image.rb'

def tick(args)
  # Create a panel
  panel = Hoard::UI::Panel.new(
    x: 100, y: 600, w: 400, h: 300,
    background: [30, 30, 40, 255],
    border: true
  ) do
    # Add a button
    button(h: 50, on_click: -> { puts "Clicked!" }) do
      label(align: :center, vertical_align: :center) { "Click Me" }
    end
  end

  # Layout, update, and render
  panel.layout
  panel.update(args)
  panel.render(args)
end
```

## Components

### Box
The fundamental layout component. Can contain children and lay them out horizontally or vertically.

```ruby
Box.new(
  x: 0, y: 720,           # Position (top-left corner in DragonRuby coords)
  w: 400, h: 300,         # Size (can be nil for auto-sizing)
  direction: :vertical,   # :vertical or :horizontal
  gap: 10,                # Space between children
  padding: 10,            # Inner padding
  background: [r, g, b, a],  # Background color
  border: true,           # Show border
  border_color: [r, g, b, a] # Border color
) do
  # Child elements...
end
```

**Layout Directions:**
- `:vertical` - Children stack top to bottom (default)
- `:horizontal` - Children flow left to right

**Size Options:**
- Explicit: `w: 400, h: 300`
- Percentage: `w: "50%"` (50% of parent width)
- Auto: `w: nil` (size to fit children)

### Label
Renders text with alignment options.

```ruby
label(
  text: "Hello",          # Static text, or use block
  size_enum: 0,           # DragonRuby text size (0-10)
  color: [255, 255, 255, 255],  # Text color
  align: :center,         # :left, :center, :right
  vertical_align: :center # :top, :center, :bottom
) { "Dynamic text" }
```

### Button
An interactive box with hover states and click handlers.

```ruby
button(
  w: 200, h: 50,
  on_click: -> { puts "Clicked!" },
  normal_color: [50, 50, 50, 200],
  hover_color: [100, 100, 100, 200],
  pressed_color: [150, 150, 150, 200]
) do
  label(align: :center, vertical_align: :center) { "Click Me" }
end
```

### Panel
A draggable window/container. Extends Box with drag functionality.

```ruby
Panel.new(
  x: 100, y: 600,
  w: 800, h: 500,
  draggable: true,  # Can be dragged (default: true)
  background: [30, 30, 40, 255],
  border: true
) do
  # Contents...
end
```

### Image
Renders sprites and tilesheets.

```ruby
image(
  path: 'sprites/player.png',
  w: 64, h: 64,
  tile_x: 0, tile_y: 0,    # For spritesheets
  tile_w: 64, tile_h: 64,
  angle: 0,
  flip_horizontally: false,
  flip_vertically: false,
  color: [255, 255, 255, 255]
)
```

## Layout System

The UI system uses a simple, explicit layout model:

1. **Build** - Create UI tree using nested components
2. **Layout** - Calculate positions (call once per frame)
3. **Update** - Handle interactions
4. **Render** - Draw to screen

```ruby
# Build
panel = Panel.new(...) { ... }

# Layout (calculates all positions)
panel.layout

# Update (handle clicks, hovers, etc)
panel.update(args)

# Render (draw to screen)
panel.render(args)
```

## Examples

### Vertical Stack
```ruby
box(direction: :vertical, gap: 10) do
  label { "Item 1" }
  label { "Item 2" }
  label { "Item 3" }
end
```

### Horizontal Row
```ruby
box(direction: :horizontal, gap: 20) do
  button(w: 100) { label { "Left" } }
  button(w: 100) { label { "Middle" } }
  button(w: 100) { label { "Right" } }
end
```

### Nested Layout
```ruby
box(direction: :vertical) do
  # Header
  box(h: 50, background: [50, 50, 60, 255]) do
    label(align: :center, vertical_align: :center) { "Header" }
  end

  # Content with columns
  box(direction: :horizontal, gap: 10) do
    # Left column
    box(w: "30%", background: [40, 40, 50, 255]) do
      label { "Sidebar" }
    end

    # Right column
    box(w: "70%", background: [40, 40, 50, 255]) do
      label { "Main content" }
    end
  end
end
```

### Interactive UI
```ruby
Panel.new(x: 100, y: 600, w: 400, h: 300) do
  box(direction: :vertical, gap: 10) do
    label(size_enum: 2) { "Counter: #{@count}" }

    box(direction: :horizontal, gap: 10) do
      button(on_click: -> { @count += 1 }) do
        label { "+" }
      end

      button(on_click: -> { @count -= 1 }) do
        label { "-" }
      end
    end
  end
end
```

## Key Differences from Old UI System

**Old System Problems:**
- Complex coordinate calculations with rx/ry confusion
- Recursive width/height calculations causing bugs
- Convoluted grid layout (Col/Row with spans)
- Padding/margin accumulation issues
- Difficult to debug

**New System Benefits:**
- Explicit positioning - no magic
- Single-pass layout calculation
- Simple flex-style direction (vertical/horizontal)
- Clear component hierarchy
- Predictable behavior
- Easy to debug

## Tips

1. **Always call `.layout()` before `.render()`**
2. **Use explicit sizes when possible** - prevents calculation overhead
3. **Use keys for stateful components** - enables proper state tracking
4. **Build UI once, update dynamic content** - use blocks for dynamic text
5. **Use Box for everything** - it's your layout workhorse

## State Management

Each component has access to persistent state:

```ruby
button(key: :my_button, on_click: -> {
  # Access state
  state[:click_count] ||= 0
  state[:click_count] += 1
})
```

State is keyed by component key and persists across frames.

## Performance

- Layout calculation is O(n) where n is number of components
- Rendering is direct - no intermediate calculations
- State is cached per component
- Text size calculations are cached

For best performance:
- Reuse component instances when possible
- Use explicit sizes to skip auto-calculation
- Minimize deep nesting

## Accessing Widget Context with method_missing

UI elements can access instance variables and methods from the widget context using `method_missing`. This makes it easy to build dynamic UIs that respond to widget state.

### How it works

When you access a variable or method inside a UI block:
1. First checks if it's an option on the current element
2. Then checks the parent element
3. Finally checks the widget (if `widget: self` was passed)

### Example

```ruby
class MyWidget < Hoard::Widget
  def init
    @counter = 0
    @player_name = "Hero"
  end

  def increment
    @counter += 1
  end

  def render
    panel = Panel.new(widget: self) do  # Pass widget reference
      # Access @counter via method_missing
      label { "Count: #{counter}" }

      # Access @player_name
      label { "Player: #{player_name}" }

      # Call widget method
      button(on_click: -> { increment }) do
        label { "Click me!" }
      end

      # Access element options
      box(custom_value: 123) do
        label { "Value: #{custom_value}" }
      end
    end

    panel.layout
    panel.update(args)
    panel.render(args)
  end
end
```

### Important: Pass widget reference

For method_missing to work with widget ivars, you must pass `widget: self`:

```ruby
Panel.new(widget: self) do  # ✅ Good - can access widget ivars
  label { "Name: #{player_name}" }
end

Panel.new do  # ❌ Won't work - no widget reference
  label { "Name: #{player_name}" }  # Error!
end
```

## See Also

- `example.rb` - Complete working example
- `example_method_missing.rb` - method_missing examples
- `base_element.rb` - Base class with method_missing logic
- `box.rb` - Core layout component
- `label.rb` - Text rendering
- `button.rb` - Interactive buttons
- `panel.rb` - Draggable windows
- `image.rb` - Sprite rendering
