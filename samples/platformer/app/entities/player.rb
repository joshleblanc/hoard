class Player < Hoard::Entity 
    script Hoard::Scripts::PlatformerPlayerScript.new

    script Hoard::Scripts::AnimationScript.new(:idle, {
        frames: 1,
        y: 0,
        x: 0,
        path: "samples/platformer/sprites/spritesheet-characters-default.png",
        tile_w: 128,
        tile_h: 128,
    })

    script Hoard::Scripts::AnimationScript.new(:standing_jump, {
        frames: 1,
        y: 128,
        x: 0,
        path: "samples/platformer/sprites/spritesheet-characters-default.png",
        tile_w: 128,
        tile_h: 128,
    })

    script Hoard::Scripts::DebugRenderScript.new

    def initialize(opts)
        opts[:tile_w] = 128
        opts[:tile_h] = 128
        opts[:anchor_y] = 1
        super(opts)
    end

    def init
        send_to_scripts(:play_animation, :idle, true)
    end
end