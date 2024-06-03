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
            scripts = self.class.instance_variable_get(:@scripts) || []
            scripts.each do |script|
                add_script(script)
            end
        end

        
        def add_script(script)
            scripts << script
            script.entity = self
            self.define_singleton_method(Utils.underscore(script.class.name).to_sym) { script }
            script.init
        end

        def scripts 
            @scripts ||= []
        end

        def find_scripts(what)
            @scripts.select { _1.is_a? what }
        end

        def send_to_scripts(met, *args, &blk)
            scripts.each do |script|
                script.send(met, *args, &blk) if script.respond_to?(met)
            end
        end

        def find_script_property(name)
            self.class.find_script_property(name, scripts)
        end
    end
end