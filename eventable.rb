module Hoard 
    module Eventable 
        def self.included(base)
            base.extend(ClassMethods)
        end

        module ClassMethods
            def event(name)
                @events ||= []
                @events << name
            end
        end

        def add_default_events!
            events = []

            # Walk up the inheritance chain to collect all events
            klass = self.class
            while klass.respond_to?(:instance_variable_get)
                class_events = klass.instance_variable_get(:@events)
                events.concat(class_events) if class_events

                break unless klass.superclass && klass.superclass.included_modules.include?(Eventable)
                klass = klass.superclass
            end

            # Add widgets in reverse order so parent widgets come first
            events.reverse.each do |event|
                add_event(event.dup)
            end
        end

        def add_event(event)
            events << event
            self.define_singleton_method(Utils.underscore(event.class.name).to_sym) { event }
        end

        def events
            @events ||= []
        end

        def find_events(what)
            @events.select { _1.is_a? what }
        end
    end
end