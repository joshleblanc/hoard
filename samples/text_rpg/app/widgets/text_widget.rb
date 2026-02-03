class TextWidget < Hoard::Widget
    attr_accessor :text, :title

    def initialize(title: nil, **opts)
        super(**opts)
        @text = ""
        @title = title
        @visible = true
    end

    def render
        return unless @visible

        x = 920
        y = Game::SCREEN_H - 50
        w = 300
        h = 450

        args.outputs.borders << { x: x, y: y - h, w: w, h: h, r: 40, g: 40, b: 50 }
        args.outputs.solids << { x: x, y: y - h, w: w, h: h, r: 25, g: 25, b: 35 }

        if @title
            args.outputs.labels << {
                x: x + 10,
                y: y - 10,
                text: @title,
                size_enum: 3,
                r: 180, g: 180, b: 180
            }
        end

        lines = @text.to_s.split("\n")
        line_y = y - 40
        lines.each do |line|
            args.outputs.labels << {
                x: x + 10,
                y: line_y,
                text: line,
                size_enum: 2,
                r: 200, g: 200, b: 200
            }
            line_y -= 20
        end

        if @instructions
            args.outputs.labels << {
                x: x + 10,
                y: line_y - 20,
                text: "---",
                size_enum: 1,
                r: 100, g: 100, b: 100
            }
            line_y -= 15
            @instructions.each_with_index do |inst, i|
                args.outputs.labels << {
                    x: x + 10,
                    y: line_y - (i * 15),
                    text: inst,
                    size_enum: 1,
                    r: 100, g: 100, b: 100
                }
            end
        end
    end

    def visible?
        @visible
    end

    def visible=(val)
        @visible = val
    end
end
