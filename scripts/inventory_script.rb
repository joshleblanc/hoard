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

            def add_to_inventory(loot)
                if @slots.length < @size 
                    @slots << loot

                    Game.s.player.send_to_scripts(:add_notification, 
                        Game.s.root.enum("Item").find(loot).tile_rect,
                        "Received 1 #{loot}"
                    )
                end
        
            end
        
            def post_update
                return unless @open
                    
                container = $args.layout.rect(row: 0, col: 0, w: 5, h: 6)
        
                $args.outputs[:ui].sprites << container.merge({
                    path: "sprites/ui/png/yellow_panel.png"
                })
        
                @size.times do |i|
                    layout = $args.layout.rect(row: (i / 4).floor, col: (i % 4), w: 1, h: 1)
                    $args.outputs[:ui].sprites << layout.merge({
                        x: layout.x + 25,
                        y: layout.y - 25,
                        path: "sprites/ui/png/blue_panel.png",
                    })
        
                    next unless @slots[i]
        
                    icon_tileset = Game.s.root.enum("Item").find(@slots[i]).tile_rect
        
                    tileset = icon_tileset.tileset
                    $args.outputs[:ui].sprites << layout.merge({
                        x: layout.x + 25,
                        y: layout.y - 25,
                        path: tileset.rel_path.gsub("../../", ""),
                        tile_x: icon_tileset.x,
                        tile_y: icon_tileset.y,
                        tile_w: tileset.tile_grid_size,
                        tile_h: tileset.tile_grid_size,
                    })
                end
            end
        end
    end
end