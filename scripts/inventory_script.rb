module Hoard
    module Scripts 
        class InventoryScript < Hoard::Script
            def initialize(size = 20)
                @size = size
                @slots = []

                @open = false
            end

            def open! 
                @open = true
            end
        
            def close!
                @open = false
            end

            def open?
                @open
            end

            def toggle!
                if open? 
                    close!
                else
                    open!
                end
            end

            def add_to_inventory(loot, quantity = 1)
                return unless loot.inventory_spec_script 

                spec = loot.inventory_spec_script

                if @slots.length < @size 
                    @slots << {
                        icon: spec.icon,
                        quantity: quantity 
                    }

                    entity.send_to_scripts(:add_notification, 
                        spec.icon,
                        "Received #{quantity} #{spec.name}"
                    )
                end
        
            end

            def update 
                if inputs.keyboard.key_down.q
                    toggle!
                end
            end
        
            def post_update
                return unless @open
                    
                container = layout.rect(row: 1, col: 0, w: 5, h: 6)
        
                outputs[:ui].sprites << container.merge({
                    primitive_marker: :solid,
                    r: 0, b: 0, g: 0, a: 125,
                })

                outputs[:ui].primitives << container.merge({
                    primitive_marker: :border,
                    r: 0, b: 0, g: 0, a: 255
                })

                @size.times do |i|
                    l = layout.rect(row: (i / 4).floor + 1, col: (i % 4), w: 1, h: 1)
                    outputs[:ui].sprites << l.merge({
                        x: l.x + 25,
                        y: l.y - 25,
                        r: 0, g: 0, b: 0, a: 125,
                        primitive_marker: :solid,
                    })

                    outputs[:ui].primitives << l.merge({
                        x: l.x + 25,
                        y: l.y - 25,
                        r: 0, g: 0, b: 0, a: 255,
                        primitive_marker: :border
                    })
        
                    next unless @slots[i]

                    item = @slots[i]
        
                    outputs[:ui].sprites << l.merge({
                        x: l.x + 25,
                        y: l.y - 25,
                        path: item.icon.path,
                        tile_x: item.icon.tile_x,
                        tile_y: item.icon.tile_y,
                        tile_w: item.icon.tile_w,
                        tile_h: item.icon.tile_h,
                    })

                    outputs[:ui].labels << l.merge({
                        x: l.x + 27,
                        y: l.y + 20,
                        text: item.quantity,
                        r: 255, g: 255, b: 255,
                        size_px: 12,
                    })
                end
            end
        end
    end
end