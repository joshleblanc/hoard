module Hoard 
    class Layer 
        attr_sprite

        def initialize(path)
            @x = 0
            @y = 0
            @w = 1280
            @h = 720

            @scale_x = 1
            @scale_y = 1

            @original_width = @w
            @original_height = @h

            @path = path
        end

        def scale=(new_scale)
            @scale_x = new_scale
            @scale_y = new_scale
        end

        def draw_override(ffi_draw) 
            ffi_draw.draw_sprite_hash({
                x: @x,
                y: @y,
                w: @w * @scale_x,
                h: @h * @scale_y,
                path: @path
            })
        end
    end
end