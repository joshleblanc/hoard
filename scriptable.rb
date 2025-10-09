module Hoard
  module Scriptable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def script(what)
        @scripts ||= []
        @scripts << what
      end

      def find_script_property(name, scripts = nil)
        scripts = scripts || @scripts

        ivar = :"@#{name}"
        scripts.each do |script|
          next unless script.instance_variables.include?(ivar)

          return script.instance_variable_get(ivar)
        end
      end
    end

    def add_default_scripts!
      scripts = []

      # Walk up the inheritance chain to collect all scripts
      klass = self.class
      while klass.respond_to?(:instance_variable_get)
        class_scripts = klass.instance_variable_get(:@scripts)
        scripts.concat(class_scripts) if class_scripts

        # Stop when we reach Scriptable module or a class that doesn't have included Scriptable
        break unless klass.superclass && klass.superclass.included_modules.include?(Scriptable)
        klass = klass.superclass
      end

      # Add scripts in reverse order so parent scripts come first
      scripts.reverse.each do |script|
        add_script(script.dup)
      end
    end

    def add_script(script)
      scripts << script
      script.entity = self
      self.define_singleton_method(Utils.underscore(script.class.name).to_sym) { script }
    end

    def scripts
      @scripts ||= []
    end

    def find_scripts(what)
      @scripts.select { _1.is_a? what }
    end

    def send_to_scripts(met, *args, &blk)
      scripts.each do |script|
        if script.respond_to?(met)
          unless script.init_once_done || met.to_s.include?("=")
            script.args = $args unless script.args
            script.init
            script.init_once_done = true
          end

          script.send(met, *args, &blk) unless met == :init
        end
      end
    end

    def find_script_property(name)
      self.class.find_script_property(name, scripts)
    end
  end
end
