module Hoard 
    module Scriptable 
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
            ivar = :"@#{name}"
            scripts.each do |script|
                next unless script.instance_variables.include?(ivar)
                
                return script.instance_variable_get(ivar)
            end
        end
    end
end