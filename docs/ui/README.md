# Hoard UI System

The Hoard UI system provides a flexible and powerful way to create user interfaces for your games. It's built on a hierarchical component system with automatic layout management, event handling, and theming support.

## Table of Contents

1. [Overview](#overview)
2. [Core Concepts](#core-concepts)
   - [Elements](#elements)
   - [Layout System](#layout-system)
   - [Event Handling](#event-handling)
   - [Element Pooling](#element-pooling)
3. [Built-in Components](#built-in-components)
   - [Element](#element)
   - [Window](#window)
   - [Button](#button)
   - [Text](#text)
   - [Image](#image)
   - [Row](#row)
   - [Col](#col)
4. [Theming](#theming)
5. [Best Practices](#best-practices)
6. [Examples](#examples)

## Overview

The Hoard UI system is designed to be:
- **Declarative**: Define your UI structure using a clean, hierarchical syntax
- **Responsive**: Automatic layout management with flexible sizing
- **Efficient**: Built-in element pooling for optimal performance
- **Extensible**: Easy to create custom UI components
- **Themable**: Consistent styling across your application

## Core Concepts

### Elements

All UI components inherit from the base `Element` class, which provides:
- Position and size management
- Parent-child relationships
- Basic rendering capabilities
- Event handling
- State management

### Layout System

The layout system uses a 12-column grid with `Row` and `Col` components:
- `Row`: Groups elements horizontally
- `Col`: Defines columns within a row (spans 1-12 columns)
- Automatic wrapping and responsive behavior

### Event Handling

Elements support various events:
- `on_click`: Triggered when the element is clicked
- `on_mouse_enter`: When the mouse enters the element
- `on_mouse_exit`: When the mouse leaves the element

### Element Pooling

The `ElementPool` manages UI elements to minimize garbage collection:
- Reuses elements when possible
- Automatically manages element lifecycle
- Improves performance for dynamic UIs

## Built-in Components

### Element

Base class for all UI elements.

```ruby
# Basic element with custom rendering
class CustomElement < Hoard::Ui::Element
  def render
    # Draw a red rectangle
    solid x: rx, y: ry, w: rw, h: rh, r: 255, g: 0, b: 0
  end
end
```

### Window

A draggable container with a title bar.

```ruby
window key: :my_window, x: 100, y: 100, w: 300, h: 200 do |w|
  # Window contents
  text "Window Title", size_enum: 2, align: :center
  
  # Add more elements...
end
```

### Button

An interactive button with hover and click states.

```ruby
button key: :my_button, w: 100, h: 40, on_click: -> { puts "Clicked!" } do
  text "Click Me", align: :center, valign: :middle
end
```

### Text

Displays formatted text with automatic wrapping.

```ruby
text "This is some sample text that will automatically wrap to fit its container.",
  size_enum: 1,
  justify: :left,
  align: :top
```

### Image

Displays an image.

```ruby
image path: 'sprites/icon.png', w: 64, h: 64
```

### Row

Groups elements horizontally.

```ruby
row do
  # Elements will be placed horizontally
  button "Button 1"
  button "Button 2"
end
```

### Col

Defines a column within a row (spans 1-12 columns).

```ruby
row do
  # Takes up 4/12 (1/3) of the row
  col span: 4 do
    text "Left Column"
  end
  
  # Takes up 8/12 (2/3) of the row
  col span: 8 do
    text "Right Column"
  end
end
```

## Theming

Use the `Colors` module for consistent theming:

```ruby
include Hoard::Ui::Colors

# Use predefined colors
solid x: 0, y: 0, w: 100, h: 100, **BLUE

# With transparency
solid x: 0, y: 0, w: 100, h: 100, **BLUE.merge(a: 128)
```

## Best Practices

1. **Use Keys**: Always provide unique keys for elements to enable proper pooling
2. **Leverage Layout**: Use `Row` and `Col` for responsive layouts
3. **Reuse Elements**: Update existing elements instead of creating new ones
4. **Group Related Elements**: Use containers to group related UI elements
5. **Keep State in Elements**: Use element state for UI-specific data
6. **Use Constants for Keys**: Avoid typos by using symbol constants for element keys

## Examples

### Simple Form

```ruby
window key: :login_window, x: 100, y: 100, w: 300, h: 200 do
  col padding: 10 do
    text "Login", size_enum: 2, align: :center
    
    row do
      text "Username:", w: 80
      text_field key: :username, w: 200
    end
    
    row do
      text "Password:", w: 80
      text_field key: :password, w: 200, password: true
    end
    
    button key: :login_btn, h: 30, on_click: -> { handle_login } do
      text "Login", align: :center, valign: :middle
    end
  end
end
```

### HUD Element

```ruby
class Hud < Hoard::Ui::Element
  def initialize
    super(key: :hud)
    
    @health = 100
    @score = 0
  end
  
  def update
    # Update HUD state
  end
  
  def render
    # Health bar
    solid x: 10, y: 10, w: 200, h: 20, r: 50, g: 50, b: 50
    solid x: 10, y: 10, w: @health * 2, h: 20, r: 255, g: 0, b: 0
    
    # Score
    text "Score: #{@score}", x: 10, y: 40, size_enum: 1
  end
end
```

### Custom Component

```ruby
class ProgressBar < Hoard::Ui::Element
  attr_accessor :value, :max_value
  
  def initialize(**opts)
    super(**opts)
    @value = opts[:value] || 0
    @max_value = opts[:max_value] || 100
    @background = opts[:background] || { r: 50, g: 50, b: 50 }
    @fill = opts[:fill] || { r: 0, g: 255, b: 0 }
  end
  
  def render
    # Draw background
    solid x: rx, y: ry, w: rw, h: rh, **@background
    
    # Draw fill
    fill_width = (@value.to_f / @max_value) * rw
    solid x: rx, y: ry, w: fill_width, h: rh, **@fill
    
    # Draw text
    text "#{@value}/#{@max_value}", 
      x: rx + (rw / 2), 
      y: ry + (rh / 2), 
      align: :center, 
      valign: :middle
  end
end

# Usage
progress_bar = ProgressBar.new(
  key: :health_bar,
  x: 10, y: 10, w: 200, h: 20,
  value: 75,
  max_value: 100,
  background: { r: 30, g: 30, b: 30 },
  fill: { r: 255, g: 0, b: 0 }
)
```

This documentation covers the core concepts and components of the Hoard UI system. For more advanced usage, refer to the source code and experiment with different component combinations.
