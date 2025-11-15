# Example: Using method_missing to access parent context and widget ivars
# This demonstrates how UI elements can access variables from the widget scope

require_relative 'ui.rb'

module Hoard
  module UI
    class MethodMissingExample < Widget
      def init
        @counter = 0
        @player_name = "Hero"
        @health = 100
        @max_health = 100
      end

      def increment_counter
        @counter += 1
      end

      def decrement_counter
        @counter -= 1
      end

      def reset_counter
        @counter = 0
      end

      def render
        # Build UI - blocks can access widget ivars via method_missing!
        panel = Panel.new(
          key: :example_panel,
          x: 100,
          y: 600,
          w: 600,
          h: 400,
          padding: 10,
          background: [30, 30, 40, 255],
          border: true,
          widget: self  # Pass widget reference to enable method_missing
        ) do
          # Title
          box(h: 50, background: [50, 50, 60, 255], padding: 5) do
            # Accessing @player_name from widget via method_missing
            label(size_enum: 2, align: :center, vertical_align: :center) {
              "#{player_name}'s Stats"  # player_name resolves via method_missing!
            }
          end

          # Health bar
          box(direction: :vertical, gap: 5, padding: 10) do
            label { "Health" }
            box(direction: :horizontal, h: 30, background: [20, 20, 20, 255]) do
              # Health bar fill - accessing @health and @max_health
              box(
                w: "#{(health.to_f / max_health * 100).to_i}%",
                background: [200, 50, 50, 255]
              )
            end
            label(size_enum: -1) { "#{health} / #{max_health}" }
          end

          # Counter section
          box(direction: :vertical, gap: 10, padding: 10) do
            # Display counter value - accessing @counter
            label(size_enum: 3, align: :center) { "Counter: #{counter}" }

            # Buttons that call widget methods
            box(direction: :horizontal, gap: 10, h: 50) do
              button(
                w: 150,
                # Calling widget method via method_missing
                on_click: -> { increment_counter }
              ) do
                label(align: :center, vertical_align: :center) { "Increment" }
              end

              button(
                w: 150,
                on_click: -> { decrement_counter }
              ) do
                label(align: :center, vertical_align: :center) { "Decrement" }
              end

              button(
                w: 150,
                on_click: -> { reset_counter }
              ) do
                label(align: :center, vertical_align: :center) { "Reset" }
              end
            end
          end

          # Info box accessing multiple widget variables
          box(
            h: 80,
            background: [20, 30, 40, 255],
            padding: 10,
            border: true
          ) do
            label(size_enum: 1) {
              # Complex string interpolation with multiple widget ivars
              "Player: #{player_name} | Health: #{health}/#{max_health} | Counter: #{counter}"
            }
          end

          # Example showing option access via method_missing
          box(
            custom_data: "I'm custom!",
            another_option: 42,
            padding: 5
          ) do
            # Access options directly as methods
            label { "Custom data: #{custom_data}" }
            label { "Another option: #{another_option}" }
          end
        end

        # Layout and render
        panel.layout
        panel.update(args)
        panel.render(args)
      end
    end
  end
end

# Usage in your game:
# def tick(args)
#   args.state.example ||= Hoard::UI::MethodMissingExample.new
#   args.state.example.args = args
#   args.state.example.post_update
# end

# How method_missing works in UI:
#
# 1. Access widget instance variables:
#    label { "Name: #{player_name}" }
#    - Looks for @player_name in widget
#
# 2. Call widget methods:
#    button(on_click: -> { increment_counter })
#    - Calls increment_counter method on widget
#
# 3. Access element options:
#    box(custom_value: 123) do
#      label { "Value: #{custom_value}" }  # Accesses option directly
#    end
#
# 4. Access parent methods/options:
#    - If not found in current element, checks parent
#    - If not found in parent, checks widget
#    - Chain continues up the tree until found
