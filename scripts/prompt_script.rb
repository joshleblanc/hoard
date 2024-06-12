module Hoard 
    module Scripts 
        class PromptScript < Script 
            attr :prompt

            def initialize 
                @active = true
            end

            def disable!
                @active = false 
            end

            def enable!
                @active = true
            end

            def active?
                @active
            end

            def on_collision(player)
                return unless active?
                 
                outputs[:scene].labels << { 
                    x: entity.x,
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