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
    end
end