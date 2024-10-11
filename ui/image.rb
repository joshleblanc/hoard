module Hoard 
    module Ui
        class Image < Element 
            def render 
                $gtk.notify! [rx, ry, rw, rh]
                $args.outputs[:ui].sprites << {
                    x: rx, y: ry, w: rw, h: rh,
                    **@options,
                }
            end
        end
    end
end