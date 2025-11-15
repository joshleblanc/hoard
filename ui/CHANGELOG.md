# UI Changelog

## Latest Update: BaseElement with method_missing

### Added
- **BaseElement** base class that all UI elements inherit from
- **method_missing** support for accessing:
  - Element options as methods (e.g., `background`, `padding`)
  - Parent element methods and variables
  - Widget instance variables and methods
- **respond_to_missing?** for proper method introspection
- **find_widget** traverses up the tree to find widget context
- Shared helper methods (`parse_color`, `mouse_inside?`, `state`)

### Changed
- Box, Label, Image now inherit from BaseElement
- Button inherits from Box (gets BaseElement transitively)
- Panel inherits from Box (gets BaseElement transitively)
- Removed duplicate code from all element classes
- Consolidated common functionality in BaseElement

### Benefits
1. **Access widget ivars in UI blocks:**
   ```ruby
   panel = Panel.new(widget: self) do
     label { "Counter: #{counter}" }  # Accesses @counter from widget
   end
   ```

2. **Call widget methods:**
   ```ruby
   button(on_click: -> { increment_counter })  # Calls widget method
   ```

3. **Access options as methods:**
   ```ruby
   box(custom_value: 123) do
     label { "Value: #{custom_value}" }  # Accesses option directly
   end
   ```

4. **Cleaner code:**
   - No more `@options[:background]` - just use `background`
   - No more `@parent.send(:method)` - just call `method`
   - Less boilerplate in element classes

### Example Usage

```ruby
class MyWidget < Hoard::Widget
  def init
    @health = 100
    @max_health = 100
  end

  def heal
    @health = @max_health
  end

  def render
    Panel.new(widget: self, x: 100, y: 600, w: 400, h: 200) do
      # Access widget ivars
      label { "Health: #{health} / #{max_health}" }

      # Call widget methods
      button(on_click: -> { heal }) do
        label { "Heal" }
      end
    end.tap do |panel|
      panel.layout
      panel.update(args)
      panel.render(args)
    end
  end
end
```

### Files Added
- `base_element.rb` - Base class with method_missing
- `example_method_missing.rb` - Comprehensive examples

### Files Modified
- `box.rb` - Now inherits from BaseElement
- `label.rb` - Now inherits from BaseElement
- `image.rb` - Now inherits from BaseElement
- `ui2.rb` - Requires base_element first
- `README.md` - Added method_missing documentation

### Migration Notes
No breaking changes! The API is 100% backward compatible. Just add `widget: self` to your root Panel/Box to enable method_missing for widget context.
