# https://github.com/deepnight/deepnightLibs/blob/master/src/dn/struct/RecyclablePool.hx

module Hoard
    class RecyclablePool

        attr :size, :nalloc, :pool

        def initialize(size, klass) 
            @size = size
            @pool = []
            @nalloc = 0
            size.times do
                @pool << klass.new
            end
        end

        def get(index)
            pool[index]
        end

        def [](index)
            get(index)
        end

        def get_unsafe(index)
            get(index)
        end

        def dispose(disposer = nil)
            if disposer 
                pool.each { |el| disposer.call(el) }
            end
            @nalloc = 0
            @pool = nil
        end

        def alloc 
            if @nalloc >= @size 
                garbage_collect_now
                if @nalloc >= @size 
                    raise StandardError.new("RecyclablePool limit reached (#{@size})")
                end
            end

            e = pool[@nalloc.next]
            e.recycle

            e
        end

        def can_be_garbage_collected?(v)
            false
        end

        def garbage_collect_now
            @nalloc.times do |i|
                next unless can_be_garbage_collected? get(i)
                                        
                free_index(i)   
            end
        end

        def free_all 
            @nalloc = 0
        end

        def find(&blk)
            @pool.find(&blk)
        end

        def free_index(i)
            return unless i >= 0 && i < @nalloc

            if i == @nalloc.pred 
                @nalloc = @nalloc - 1
            else 
                tmp = @pool[i]
                @pool[i] = @pool[@nalloc.pred]
                @pool[@nalloc.pred] = tmp
                @nalloc = @nalloc - 1
            end
        end

        def free_element(search)
            index = @pool.find_index do |el|
                el == search
            end

            free_index index if index
        end

    end
end