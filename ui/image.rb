module Hoard 
    module Ui
        class Image < Element 
            def render 
                $args.outputs[:ui].sprites << {
                    **@options,
                    x: rx, y: ry, w: rw, h: rh,
                }
            end
        end
    end
end