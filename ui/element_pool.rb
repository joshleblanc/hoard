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

        # p pool_key if pool_key.include?("Col")
        
        element = @pools[pool_key][parent&.key]

        if element
          # Update existing element if options changed
          element.update_options(**options, &blk)
        else
          # Create new element if none exists
          element = element_class.new(parent: parent, **options, &blk)
          @pools[pool_key][parent&.key] = element
        end

        element
      end

      def release(element)
        pool_key = "#{element.class.name}::#{element.key}"
        parent_key = element.parent&.key
        @pools[pool_key]&.delete(parent_key) if @pools[pool_key]
      end

      def clear
        @pools.clear
      end
    end
  end
end
