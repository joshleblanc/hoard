module Hoard 
    module Scriptable 
        def add_script(script)
            scripts << script
            script.entity = self
            script.init
        end

        def scripts 
            @scripts ||= []
        end

        def send_to_scripts(met, *args)
            scripts.each do |script|
                script.send(met, *args) if script.respond_to?(met)
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