module Hoard
  module Scripts
    class InventoryScript < Hoard::Script
      def initialize(size = 20)
        @size = size
        @slots = []
      end

      def init
        @widget = entity.inventory_widget
        load!
      end

      def load!
        save_data = entity.save_data_script.init
        items = save_data.inventory || []
        items.each do |item|
          spec = InventorySpecScript[item[:name]]
          add_to_inventory(spec, item[:quantity], true)
        end
      end

      def has_enough?(what, quantity = 1)
        (find(what)&.quantity || 0) >= quantity
      end

      def can_afford?(what, quantity = 1)
        has_enough?(what, quantity)
      end

      def find(what)
        @slots.find { _1.name == what }
      end

      def add_to_inventory(spec, quantity = 1, quiet = false)
        if @slots.length < @size
          existing_item = @slots.find { _1.name == spec.name }
          if existing_item
            existing_item.quantity += quantity
          else
            @slots << {
              **spec.to_h,
              quantity: quantity,
            }
          end

          entity.send_to_scripts(:save, { inventory: @slots.map {{ quantity: _1.quantity, name: _1.name }} })

          entity.send_to_scripts(:add_notification,
                                 spec.icon,
                                 "Received #{quantity} #{spec.name}") unless quiet
        end
      end

      def remove_from_inventory(what, quantity = 1)
        item = find(what)
        return unless item

        if quantity > item.quantity
          item.quantity -= quantity
        else
          @slots.delete item
        end

        entity.send_to_scripts(:save, { inventory: @slots })
      end

      def post_update
        @widget.slots = @slots
        @widget.size = @size
      end
    end
  end
end
