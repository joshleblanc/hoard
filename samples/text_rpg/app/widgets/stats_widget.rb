class StatsWidget < Hoard::Widget
    attr_accessor :stats

    def initialize(**opts)
        super(**opts)
        @stats = {}
        @visible = true
    end

    def render
        return unless @visible

        base_y = Game::SCREEN_H - 50
        x = 420

        w = 220
        h = 200

        args.outputs.borders << rect(x, base_y - h, w, h, [40, 40, 50])
        args.outputs.solids << solid(x, base_y - h, w, h, [30, 30, 40])

        label(x + 10, base_y - 10, "STATS", size_enum: 3, r: 180, g: 180, b: 180)

        y = base_y - 35
        label(x + 10, y, "HP: #{@stats[:hp] || 0}/#{@stats[:max_hp] || 0}", size_enum: 2, r: 255, g: 100, b: 100)
        y -= 22
        label(x + 10, y, "ATK: #{@stats[:attack] || 0}", size_enum: 2, r: 200, g: 200, b: 200)
        y -= 22
        label(x + 10, y, "DEF: #{@stats[:defense] || 0}", size_enum: 2, r: 200, g: 200, b: 200)
        y -= 22
        label(x + 10, y, "LVL: #{@stats[:level] || 1}", size_enum: 2, r: 255, g: 200, b: 100)
        y -= 22
        label(x + 10, y, "XP: #{@stats[:xp] || 0}/#{@stats[:xp_to_next] || 100}", size_enum: 2, r: 100, g: 200, b: 255)

        if @stats[:hp] && @stats[:max_hp]
            bar_w = w - 20
            bar_h = 12
            bar_x = x + 10
            bar_y = base_y - h + 25
            pct = @stats[:hp].to_f / @stats[:max_hp]
            args.outputs.solids << solid(bar_x, bar_y, bar_w, bar_h, [60, 60, 60])
            args.outputs.solids << solid(bar_x, bar_y, bar_w * pct, bar_h, [200, 50, 50])
        end
    end

    def visible?
        @visible
    end

    def visible=(val)
        @visible = val
    end

    private

    def rect(x, y, w, h, color)
        { x: x, y: y, w: w, h: h, r: color[0], g: color[1], b: color[2] }
    end

    def solid(x, y, w, h, color)
        { x: x, y: y, w: w, h: h, r: color[0], g: color[1], b: color[2], a: 255 }
    end

    def label(x, y, text, **opts)
        { x: x, y: y, text: text.to_s, **opts }
    end
end
