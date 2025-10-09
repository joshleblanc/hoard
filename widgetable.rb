module Hoard
  module Widgetable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def widget(what)
        @widgets ||= []
        @widgets << what
      end
    end

    def add_default_widgets!
      widgets = []

      # Walk up the inheritance chain to collect all widgets
      klass = self.class
      while klass.respond_to?(:instance_variable_get)
        class_widgets = klass.instance_variable_get(:@widgets)
        widgets.concat(class_widgets) if class_widgets

        # Stop when we reach Widgetable module or a class that doesn't have included Widgetable
        break unless klass.superclass && klass.superclass.included_modules.include?(Widgetable)
        klass = klass.superclass
      end

      # Add widgets in reverse order so parent widgets come first
      # Note: We don't duplicate widgets because they may have state that needs to persist
      widgets.reverse.each do |widget|
        add_widget(widget.dup)
      end
    end

    def add_widget(widget)
      widgets << widget
      widget.entity = self
      self.define_singleton_method(Utils.underscore(widget.class.name).to_sym) { widget }
    end

    def widgets
      @widgets ||= []
    end

    def find_widgets(what)
      @widgets.select { _1.is_a? what }
    end

    def send_to_widgets(met, *args, &blk)
      widgets.each do |widget|
        if widget.respond_to?(met)
          unless widget.init_once_done || met.to_s.include?("=")
            widget.args = $args unless widget.args
            widget.init
            widget.init_once_done = true
          end

          widget.send(met, *args, &blk) unless met == :init
        end
      end
    end
  end
end
