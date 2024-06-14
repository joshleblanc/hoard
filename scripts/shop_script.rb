module Hoard 
    module Scripts 
        class ShopScript < Script 
            def initialize 
                @open = true
            end

            def on_interact(player)

            end

            def post_update 
                return unless @open
               
                container = layout.rect(row: 1, col: 0, w: 5, h: 8)

                outputs[:ui].sprites << container.merge({
                    primitive_marker: :solid,
                    r: 0, b: 0, g: 0, a: 125
                })

                outputs[:ui].primitives << container.merge({
                    primitive_marker: :border,
                    r: 0, b: 0, g: 0, a: 255
                })

                padding = 8 
                outputs[:ui].labels << {
                    x: container.x + container.w / 2,
                    y: container.y + container.h - padding,
                    w: container.w,
                    h: 10,
                    text: "Shop!",
                    alignment_enum: 1,
                    r: 255, g: 255, b: 255, a: 255
                }

                outputs.sprites << {
                    primitive_marker: :solid,
                    w: 60,
                    h: 30,
                    x: container.x + padding,
                    y: container.y + container.h - padding - 60,
                    a: 125
                }

                outputs.labels << {
                    w: 60,
                    h: 30,
                    x: container.x + padding,
                    y: container.y + container.h - padding - 60 + 25,
                    a: 255,
                    alignment_enum: 0,
                    text: "Buy"
                }

                outputs.sprites << {
                    primitive_marker: :solid,
                    w: 60,
                    h: 30,
                    x: container.x + padding + 60 + 8,
                    y: container.y + container.h - padding - 60,
                    a: 125
                }

                outputs.sprites << {
                    primitive_marker: :solid,
                    w: container.w - (padding * 2),
                    h: container.h - (padding * 2) - 58,
                    x: container.x + padding,
                    y: container.y + padding,
                    r: 0, g: 0, b: 0, a: 125
                }
            end
        end
    end
end