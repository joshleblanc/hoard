# Example usage of the Hoard UI system
# This file demonstrates how to create various UI elements

require_relative 'box.rb'
require_relative 'label.rb'
require_relative 'panel.rb'
require_relative 'button.rb'
require_relative 'image.rb'

module Hoard
  module UI
    class Example
      def initialize(args)
        @args = args
        @panel = nil
        @counter = 0
      end

      def tick
        # Create UI tree (this is lightweight - no rendering yet)
        build_ui

        # Layout the UI (calculate all positions)
        @panel.layout

        # Update interactions
        @panel.update(@args)

        # Render
        @panel.render(@args)
      end

      def build_ui
        # Create a draggable panel
        @panel ||= Panel.new(
          key: :example_panel,
          x: 100,
          y: 600,
          w: 800,
          h: 500,
          padding: 10,
          background: [30, 30, 40, 255],
          border: true,
          border_color: [100, 100, 120, 255],
          draggable: true
        ) do
          # Title bar
          box(
            key: :title_bar,
            h: 40,
            background: [50, 50, 60, 255],
            border: true
          ) do
            label(key: :title, size_enum: 2, align: :center, vertical_align: :center) { "UI Example" }
          end

          # Content area with vertical layout
          box(
            key: :content,
            direction: :vertical,
            gap: 10,
            padding: 10
          ) do
            # Horizontal button row
            box(
              key: :button_row,
              direction: :horizontal,
              gap: 10,
              h: 50
            ) do
              button(
                key: :increment_btn,
                w: 150,
                border: true,
                on_click: -> { @counter += 1 }
              ) do
                label(align: :center, vertical_align: :center) { "Increment (#{@counter})" }
              end

              button(
                key: :decrement_btn,
                w: 150,
                border: true,
                on_click: -> { @counter -= 1 }
              ) do
                label(align: :center, vertical_align: :center) { "Decrement" }
              end

              button(
                key: :reset_btn,
                w: 150,
                border: true,
                on_click: -> { @counter = 0 }
              ) do
                label(align: :center, vertical_align: :center) { "Reset" }
              end
            end

            # Info section
            box(
              key: :info_section,
              h: 100,
              background: [20, 20, 30, 255],
              padding: 10,
              border: true
            ) do
              label(key: :counter_label, size_enum: 3, align: :center, vertical_align: :center) {
                "Counter: #{@counter}"
              }
            end

            # Image gallery (horizontal)
            box(
              key: :image_row,
              direction: :horizontal,
              gap: 10,
              h: 70
            ) do
              3.times do |i|
                box(
                  key: "image_container_#{i}",
                  w: 70,
                  h: 70,
                  padding: 5,
                  background: [60, 60, 70, 255],
                  border: true
                ) do
                  image(
                    w: 64,
                    h: 64,
                    path: 'sprites/square/blue.png'
                  )
                end
              end
            end

            # Text examples
            box(
              key: :text_section,
              h: 120,
              background: [25, 25, 35, 255],
              padding: 10,
              border: true,
              direction: :vertical,
              gap: 5
            ) do
              label(key: :left_label, align: :left) { "Left aligned text" }
              label(key: :center_label, align: :center) { "Center aligned text" }
              label(key: :right_label, align: :right) { "Right aligned text" }
            end
          end
        end
      end
    end
  end
end

# Usage in your game:
# def tick(args)
#   args.state.ui_example ||= Hoard::UI::Example.new(args)
#   args.state.ui_example.tick
# end
