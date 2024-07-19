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
      widgets = self.class.instance_variable_get(:@widgets) || []
      widgets.each do |widget|
        add_widget(widget)
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
        widget.send(met, *args, &blk) if widget.respond_to?(met)
      end
    end
  end
end
