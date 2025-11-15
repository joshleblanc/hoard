module Hoard
    class Event 
        attr_reader :name

        def initialize(name)
            @name = name
           
            @listeners = []
        end

        def connect(&block)
            @listeners << block
        end

        def emit(data = nil)
            @listeners.each { |listener| listener.call(data) }
        end
    end
end