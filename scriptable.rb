module Hoard 
    module Scriptable 
        def add_script(script)
            scripts << script
            script.entity = self
        end

        def scripts 
            @scripts ||= []
        end

        def run_scripts(met)
            scripts.each do |script|
                script.send(met)
            end
        end
    end
end