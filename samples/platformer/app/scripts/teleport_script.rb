class TeleportScript < Hoard::Script 
    attr :destination

    def level
        Hoard.config.game_class.s.root.level(iid: destination.levelIid)
    end

    def entity 
        level.entity(destination.entityIid)
    end

    def update 
        args.outputs.debug << destination.to_s
        args.outputs.debug << "TeleportScript: #{destination.entityIid} #{entity.inspect}"
    end

    def on_interact(player)
        Hoard.config.game_class.s.start_level(level)
        player.set_pos_case(entity.grid[0], entity.grid[1])
    end
end