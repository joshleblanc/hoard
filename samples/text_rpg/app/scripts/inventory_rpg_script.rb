module Hoard
    module Scripts
        class InventoryRpgScript < Hoard::Script
            attr_accessor :items, :gold

            def initialize(size: 20)
                @size = size
                @items = []
                @gold = 100
            end

            def init
                @widget = entity.inventory_widget
                @widget.items = @items
                @widget.gold = @gold
                @widget.on_use = ->(item) { use_item(item) }
                @widget.on_drop = ->(item) { drop_item(item) }
            end

            def add_item(item)
                existing = @items.find { |i| i.name == item.name && i.type == item.type }
                if existing
                    existing.quantity ||= 1
                    existing.quantity += 1
                else
                    @items << item.dup
                    item.quantity = 1
                end
                update_widget
            end

            def remove_item(item_name, quantity = 1)
                item = @items.find { |i| i.name == item_name }
                return false unless item

                if item.quantity && item.quantity > quantity
                    item.quantity -= quantity
                else
                    @items.delete(item)
                end
                update_widget
                true
            end

            def has_item?(item_name, quantity = 1)
                item = @items.find { |i| i.name == item_name }
                return false unless item
                item.quantity ||= 1
                item.quantity >= quantity
            end

            def use_item(item)
                item.use(entity)
                item.quantity ||= 1
                item.quantity -= 1
                if item.quantity <= 0
                    @items.delete(item)
                end
                update_widget
            end

            def drop_item(item)
                @items.delete(item)
                entity.add_message("Dropped #{item.name}")
                update_widget
            end

            def add_gold(amount)
                @gold += amount
                entity.add_message("Got #{amount} gold!")
                update_widget
            end

            def spend_gold(amount)
                return false unless @gold >= amount
                @gold -= amount
                update_widget
                true
            end

            def can_afford?(cost)
                @gold >= cost
            end

            def update_widget
                return unless @widget
                @widget.items = @items.dup
                @widget.gold = @gold
            end

            def post_update
            end
        end
    end
end
