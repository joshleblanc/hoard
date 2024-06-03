module Hoard 
    module Scripts 
        class PromptScript < Script 
            attr :prompt

            def on_collision(player)
                outputs[:scene].labels << { 
                    x: entity.x + (entity.w / 2),
                    y: entity.y.from_top + entity.h + 32,
                    text: prompt,
                    size_px: 8,
                    alignment_enum: 1,
                    r: 255, g: 255, b: 255, a: 255
                }
            end
        end
    end
end