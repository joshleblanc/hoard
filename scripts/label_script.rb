module Hoard 
    module Scripts
        class LabelScript < Script 
            OFFSET = 65
            BORDER_PADDING = 8

            attr :label

            def initialize(label: "")
                @label = label
            end
            
            def post_update 
                outputs[:ui].labels << {
                    x: entity.gx - entity.w / 2,
                    y: entity.gy - OFFSET,
                    text: label,
                    font_size: 1,
                    alignment_enum: 0,
                    vertical_alignment_enum: 0,
                    r: 255, g: 255, b: 255, a: 255,
                }

                tw, th = gtk.calcstringbox(label, 1)

                outputs[:ui].borders << {
                    x: entity.gx - BORDER_PADDING - entity.w / 2,
                    y: entity.gy - OFFSET - BORDER_PADDING,
                    w: (tw + BORDER_PADDING * 2) - 2,
                    h: th + BORDER_PADDING * 2,
                    r: 255, g: 255, b: 255, a: 255,
                }

                outputs[:ui].solids << {
                    x: entity.gx - BORDER_PADDING - entity.w / 2,
                    y: entity.gy - OFFSET - BORDER_PADDING,
                    w: (tw + BORDER_PADDING * 2) - 2,
                    h: th + BORDER_PADDING * 2,
                    r: 0, g: 0, b: 0, a: 125,
                }
            end
        end
    end
end