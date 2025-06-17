# Widget System

The Hoard Widget System provides a powerful way to create reusable UI components that can be attached to game entities. Widgets are self-contained components that handle their own rendering, updating, and user interaction.

## Table of Contents

1. [Overview](#overview)
2. [Widgetable Module](#widgetable-module)
   - [Basic Usage](#widgetable-basic-usage)
   - [API Reference](#widgetable-api)
3. [Widget Base Class](#widget-base-class)
   - [Lifecycle Methods](#widget-lifecycle)
   - [Rendering](#widget-rendering)
   - [Event Handling](#widget-events)
4. [Built-in Widgets](#built-in-widgets)
   - [ProgressBar](#progressbar-widget)
5. [Creating Custom Widgets](#creating-custom-widgets)
6. [Best Practices](#best-practices)

## Overview

Widgets in Hoard are designed to be:
- **Reusable**: Create once, use anywhere
- **Self-contained**: Handle their own state and rendering
- **Composable**: Combine multiple widgets to create complex UIs
- **Entity-Aware**: Can be attached to game entities

## Widgetable Module

The `Widgetable` module provides the functionality to add widgets to any class, typically game entities.

### Widgetable Basic Usage

```ruby
class Player < Hoard::Entity
  include Hoard::Widgetable
  
  def initialize
    super
    # Add default widgets
    add_default_widgets!
    
    # Or add widgets manually
    add_widget(HealthBarWidget.new)
  end
end
```

### Widgetable API

- `widget(klass)` - Declare a widget class to be automatically added
- `add_widget(widget)` - Add a widget instance
- `widgets` - Get all widgets
- `find_widgets(klass)` - Find widgets by class
- `send_to_widgets(method, *args)` - Send a message to all widgets

## Widget Base Class

All widgets should inherit from `Hoard::Widget`.

### Widget Lifecycle

1. **Initialization**: `initialize` - Called when the widget is created
2. **Pre-Update**: `pre_update` - Called before the main update
3. **Update**: `update` - Main update logic
4. **Post-Update**: `post_update` - Called after the main update
5. **Rendering**: `render` - Called to render the widget

### Widget Rendering

Widgets can render using the built-in UI system or directly using DragonRuby's rendering primitives.

```ruby
class MyWidget < Hoard::Widget
  def render
    # Using the UI system
    window(x: 100, y: 100, w: 200, h: 100, background: { r: 50, g: 50, b: 50 }) do
      text "Widget Content", size_enum: 2, align: :center, valign: :middle
    end
    
    # Or using direct rendering
    args.outputs.solids << {
      x: x, y: y, w: w, h: h,
      r: 255, g: 0, b: 0, a: 128
    }
  end
end
```

### Widget Events

Widgets can handle input events:

```ruby
def update
  if args.inputs.mouse.click && args.inputs.mouse.point.inside_rect?(bounds)
    # Handle click
  end
end
```

## Built-in Widgets

### ProgressBar Widget

A simple progress bar widget that can be used for health bars, loading indicators, etc.

```ruby
class Player < Hoard::Entity
  include Hoard::Widgetable
  
  def initialize
    super
    @health = 100
    @max_health = 100
    
    add_widget(Hoard::Widgets::ProgressBarWidget.new(limit: @max_health))
  end
  
  def take_damage(amount)
    @health = [@health - amount, 0].max
    health_bar = find_widgets(Hoard::Widgets::ProgressBarWidget).first
    health_bar&.activate! if health_bar&.idle?
  end
  
  def update
    super
    
    health_bar = find_widgets(Hoard::Widgets::ProgressBarWidget).first
    health_bar&.update
  end
end
```

## Creating Custom Widgets

To create a custom widget:

1. Create a new class that inherits from `Hoard::Widget`
2. Implement the necessary lifecycle methods
3. Handle rendering and input as needed

```ruby
module Hoard
  module Widgets
    class CustomWidget < Hoard::Widget
      def initialize
        super
        @value = 0
      end
      
      def update
        @value += 1
      end
      
      def render
        window(x: 100, y: 100, w: 200, h: 50) do
          text "Value: #{@value}", size_enum: 1, align: :center, valign: :middle
        end
      end
    end
  end
end
```

## Best Practices

1. **Keep Widgets Focused**: Each widget should have a single responsibility
2. **Use Composition**: Combine simple widgets to create complex UIs
3. **Leverage the UI System**: Use the built-in UI system for consistent styling
4. **Handle State Properly**: Manage widget state internally when possible
5. **Clean Up Resources**: Remove event listeners and clean up when widgets are destroyed
6. **Test Thoroughly**: Test widgets in isolation and in context

## Advanced Topics

### Widget Communication

Widgets can communicate through their parent entity:

```ruby
# In one widget
def on_click
  entity.find_widgets(OtherWidget).each do |widget|
    widget.do_something
  end
end
```

### Animation

Use the Tweenie system for smooth animations:

```ruby
def initialize
  super
  @tweenie = Hoard::Tweenie.new
  @animating = false
end

def animate_to(x, y)
  @tweenie.create(
    -> { [@x, @y] },
    -> (x, y) { @x = x; @y = y },
    nil,
    [x, y],
    :ease_out,
    500
  )
end
```

### Performance Optimization

For complex UIs:
- Only update widgets that need updating
- Use visibility flags to skip rendering
- Cache expensive calculations
- Consider using lower-fidelity updates for off-screen elements

This documentation covers the core concepts of the Widget System. For more advanced usage, refer to the source code and experiment with different widget combinations.
