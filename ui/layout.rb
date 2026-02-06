module Hoard
  module Ui
    module LayoutHelper
      def self.vertical(x:, y:, spacing: 8, components: [])
        current_y = y
        components.each do |c|
          c.x = x
          c.y = current_y - c.h
          current_y = c.y - spacing
        end
        components
      end

      def self.horizontal(x:, y:, spacing: 8, components: [])
        current_x = x
        components.each do |c|
          c.x = current_x
          c.y = y
          current_x += c.w + spacing
        end
        components
      end

      def self.grid(x:, y:, cols:, cell_w:, cell_h:, spacing_x: 8, spacing_y: 8, components: [])
        components.each_with_index do |c, i|
          col = i % cols
          row = i / cols
          c.x = x + col * (cell_w + spacing_x)
          c.y = y - row * (cell_h + spacing_y)
          c.w = cell_w if c.respond_to?(:w=)
          c.h = cell_h if c.respond_to?(:h=)
        end
        components
      end

      def self.center(component, within:)
        component.x = within[:x] + (within[:w] - component.w) / 2
        component.y = within[:y] + (within[:h] - component.h) / 2
        component
      end

      def self.align(component, within:, horizontal: :left, vertical: :bottom, padding: 0)
        case horizontal
        when :left   then component.x = within[:x] + padding
        when :center then component.x = within[:x] + (within[:w] - component.w) / 2
        when :right  then component.x = within[:x] + within[:w] - component.w - padding
        end

        case vertical
        when :bottom then component.y = within[:y] + padding
        when :center then component.y = within[:y] + (within[:h] - component.h) / 2
        when :top    then component.y = within[:y] + within[:h] - component.h - padding
        end

        component
      end
    end
  end
end
