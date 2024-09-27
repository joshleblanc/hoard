module Hoard 
    module Ui 
        class Window < Element
            %i(w y w h).each do |method|
                define_method(method) do 
                    if @options[method]
                        @options[method]
                    elsif parent
                        parent.send(method)
                    else
                        0
                    end
                end

                define_method("#{method}=") do |val|
                    @options[method] = val
                end
            end
        end
    end
end