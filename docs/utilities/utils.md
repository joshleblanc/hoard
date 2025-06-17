# Utils

The `Hoard::Utils` class provides various utility methods for common tasks in the Hoard game engine. Currently, it includes string manipulation helpers.

## Table of Contents

1. [Overview](#overview)
2. [Methods](#methods)
   - [underscore](#underscore)
3. [Examples](#examples)
4. [Extending Utils](#extending-utils)

## Overview

While currently minimal, the `Hoard::Utils` class is designed to be extended with additional utility methods as needed. It follows a static/class method pattern, so you don't need to instantiate it.

## Methods

### underscore

Converts a camel-cased string to snake_case.

```ruby
Hoard::Utils.underscore("CamelCaseString")  # => "camel_case_string"
Hoard::Utils.underscore("PlayerHealth")     # => "player_health"
Hoard::Utils.underscore("UIElement")        # => "ui_element"
```

**Parameters:**
- `camel_cased_word` (String) - The string to convert

**Returns:**
- (String) The snake_cased version of the input string

## Examples

### Converting Class Names to File Names

```ruby
# Convert a class name to a file name (Rails-style)
def class_to_filename(klass)
  "#{Hoard::Utils.underscore(klass.name)}.rb"
end

class_to_filename(Player)  # => "player.rb"
class_to_filename(UI::HealthBar)  # => "health_bar.rb"
```

### Dynamic Method Naming

```ruby
# Create a setter method dynamically
def create_setter(attr_name)
  method_name = "set_#{Hoard::Utils.underscore(attr_name)}"
  define_method(method_name) do |value|
    instance_variable_set("@#{Hoard::Utils.underscore(attr_name)}", value)
  end
end
```

## Extending Utils

You can easily extend the `Hoard::Utils` class with your own utility methods:

```ruby
module Hoard
  class Utils
    # Convert string to a more readable title
    def self.titleize(str)
      str.to_s.gsub(/_/, ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
    end
    
    # Generate a random string of the given length
    def self.random_string(length = 10)
      chars = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
      (0...length).map { chars[rand(chars.length)] }.join
    end
    
    # Deep clone an object (simple version)
    def self.deep_clone(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
```

### Example Usage of Extended Utils

```ruby
# Using the extended methods
title = Hoard::Utils.titleize("player_health")  # => "Player Health"
random = Hoard::Utils.random_string(8)          # => "aB3dE5gH"

# Deep cloning a hash
original = { a: 1, b: { c: 2 } }
clone = Hoard::Utils.deep_clone(original)
clone[:b][:c] = 3

original[:b][:c]  # => 2 (unchanged)
clone[:b][:c]     # => 3 (changed)
```

## Best Practices

1. **Keep it Generic**: Only add methods that have general utility across different parts of your game
2. **Namespace Appropriately**: For domain-specific utilities, consider creating a separate module/class
3. **Documentation**: Always add documentation for new utility methods
4. **Testing**: Write tests for utility methods as they're often used in many places
5. **Performance**: Be mindful of performance for utility methods that might be called frequently

### Potential Future Additions

Here are some utility methods that could be useful additions:

```ruby
module Hoard
  class Utils
    # Convert degrees to radians
    def self.deg_to_rad(degrees)
      degrees * Math::PI / 180.0
    end
    
    # Convert radians to degrees
    def self.rad_to_deg(radians)
      radians * 180.0 / Math::PI
    end
    
    # Linear interpolation between two values
    def self.lerp(a, b, t)
      a + (b - a) * t.clamp(0.0, 1.0)
    end
    
    # Format time in seconds to MM:SS.mmm
    def self.format_time(seconds)
      minutes = (seconds / 60).to_i
      seconds = seconds % 60
      "%02d:%06.3f" % [minutes, seconds]
    end
  end
end
```

This documentation covers the current functionality of the `Hoard::Utils` class and provides a pattern for extending it with additional utility methods as needed.
