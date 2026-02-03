class InventoryWidget < Hoard::Widget
    attr_accessor :items, :gold, :on_use, :on_drop, :selected_index, :visible

    def initialize(**opts)
        super(**opts)
        @items = []
        @gold = 0
        @on_use = nil
        @on_drop = nil
        @selected_index = 0
        @visible = false
    end

    def render
        return unless @visible

        x = 450
        y = Game::SCREEN_H - 100
        w = 400
        h = Game::SCREEN_H - 150

        args.outputs.borders << { x: x, y: y - h, w: w, h: h, r: 60, g: 60, b: 60 }
        args.outputs.solids << { x: x, y: y - h, w: w, h: h, r: 20, g: 20, b: 30 }

        args.outputs.labels << {
            x: x + 15,
            y: y - 10,
            text: "INVENTORY",
            size_enum: 4,
            r: 180, g: 180, b: 180
        }

        args.outputs.labels << {
            x: x + w - 15,
            y: y - 10,
            text: "Gold: #{@gold}",
            size_enum: 2,
            r: 255, g: 200, b: 100
        }

        line_y = y - 40
        @items.each_with_index do |item, i|
            is_selected = i == @selected_index
            bg_r = is_selected ? 80 : 40
            bg_g = is_selected ? 80 : 40
            bg_b = is_selected ? 80 : 50

            if is_selected
                args.outputs.solids << { x: x + 5, y: line_y - 15, w: w - 10, h: 20, r: bg_r, g: bg_g, b: bg_b }
            end

            name = item.name
            name += " x#{item.quantity}" if item.quantity && item.quantity > 1

            args.outputs.labels << {
                x: x + 15,
                y: line_y,
                text: "[#{i + 1}] #{name}",
                size_enum: 2,
                r: is_selected ? 255 : 200,
                g: is_selected ? 255 : 200,
                b: is_selected ? 255 : 200
            }

            type_label = case item.type
            when :potion then "HEAL"
            when :weapon then "WEAPON"
            when :armor then "ARMOR"
            else ""
            end

            args.outputs.labels << {
                x: x + w - 15,
                y: line_y,
                text: type_label,
                size_enum: 1,
                r: 150, g: 150, b: 150,
                alignment_enum: 2
            }

            line_y -= 25
        end

        args.outputs.labels << {
            x: x + 15,
            y: y - h + 20,
            text: "[U]se  [D]rop  [ESC]Close  [+/-]Select",
            size_enum: 1,
            r: 100, g: 100, b: 100
        }

        if @items.empty?
            args.outputs.labels << {
                x: x + w / 2,
                y: y - h / 2,
                text: "Empty",
                size_enum: 3,
                r: 100, g: 100, b: 100,
                alignment_enum: 1
            }
        end
    end

    def handle_input(key)
        return unless @visible

        case key
        when :up
            @selected_index = [@selected_index - 1, 0].max
        when :down
            @selected_index = [@selected_index + 1, [@items.length - 1, 0].max].min
        when :use
            item = @items[@selected_index]
            @on_use&.call(item)
        when :drop
            item = @items[@selected_index]
            @on_drop&.call(item)
        end
    end
end
