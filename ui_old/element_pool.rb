module Hoard
  module Ui
    class ElementPool
      def self.instance
        @instance ||= new
      end

      def initialize
        @pools = {}
      end

      def acquire(element_class, key, parent: nil, **options, &blk)
        pool_key = "#{element_class.name}::#{key}"
        @pools[pool_key] ||= {}

        parent_key = parent&.key

        # For elements with the same parent, track how many children of this type/key exist
        # This handles loops where multiple elements are created with the same key
        if parent
          @child_counters ||= {}
          counter_key = "#{parent_key}::#{pool_key}"
          @child_counters[counter_key] ||= 0

          # Find or create element with unique index
          element = @pools[pool_key]["#{parent_key}::#{@child_counters[counter_key]}"]

          if element
            # Update existing element
            element.update_options(**options, &blk)
          else
            # Create new element
            element = element_class.new(parent: parent, **options, &blk)
            @pools[pool_key]["#{parent_key}::#{@child_counters[counter_key]}"] = element
          end

          @child_counters[counter_key] += 1
        else
          # No parent - use original logic
          element = @pools[pool_key][nil]

          if element
            element.update_options(**options, &blk)
          else
            element = element_class.new(parent: parent, **options, &blk)
            @pools[pool_key][nil] = element
          end
        end

        element
      end

      def release(element)
        pool_key = "#{element.class.name}::#{element.key}"
        parent_key = element.parent&.key
        @pools[pool_key]&.delete(parent_key) if @pools[pool_key]
      end

      def reset_counters
        @child_counters&.clear
      end

      def clear
        @pools.clear
        @child_counters&.clear
      end
    end
  end
end
