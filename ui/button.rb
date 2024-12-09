module Hoard 
    module Ui 
        class Button < Element 
            def render 
                if hovered?
                    $args.outputs[:ui].sprites << {
                        x: rx, y: ry, w: rw, h: rh,
                        r: 255, g: 255, b: 255, a: 125
                    }
                else 
                    $args.outputs[:ui].sprites << {
                        x: rx, y: ry, w: rw, h: rh,
                        r: 0, g: 0, b: 0, a: 125
                    }
                end
            end
        end
    end
end
