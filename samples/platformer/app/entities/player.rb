class Player < Hoard::Entity 
    script Hoard::Scripts::PlatformerPlayerScript.new(
        health: 6
    )

    script Hoard::Scripts::AnimationScript.new(:idle, {
        files: [
            "samples/platformer/sprites/character/character_beige_idle.png"
        ]
    })

    script Hoard::Scripts::AnimationScript.new(:standing_jump, {
        files: [
            "samples/platformer/sprites/character/character_beige_jump.png"
        ]
    })

    script Hoard::Scripts::AnimationScript.new(:moving_jump, {
        files: [
            "samples/platformer/sprites/character/character_beige_jump.png"
        ]
    })

    script Hoard::Scripts::AnimationScript.new(:walk, {
        files: [
            "samples/platformer/sprites/character/character_beige_walk_a.png",
            "samples/platformer/sprites/character/character_beige_walk_b.png"
        ]
    })

    script Hoard::Scripts::AnimationScript.new(:climb, {
        files: [
            "samples/platformer/sprites/character/character_beige_climb_a.png",
            "samples/platformer/sprites/character/character_beige_climb_b.png"
        ]
    })

    script Hoard::Scripts::AudioScript.new(:footsteps, {
        files: [
            "samples/platformer/sounds/effects/footstep00.ogg",
            "samples/platformer/sounds/effects/footstep01.ogg",
            "samples/platformer/sounds/effects/footstep02.ogg",
            "samples/platformer/sounds/effects/footstep03.ogg",
            "samples/platformer/sounds/effects/footstep04.ogg",
            "samples/platformer/sounds/effects/footstep05.ogg",
            "samples/platformer/sounds/effects/footstep06.ogg",
            "samples/platformer/sounds/effects/footstep07.ogg",
            "samples/platformer/sounds/effects/footstep08.ogg",
            "samples/platformer/sounds/effects/footstep09.ogg",
        ]
    })

    script Hoard::Scripts::AudioScript.new(:jump, {
        files: [
            "samples/platformer/sounds/effects/sfx_jump.ogg"
        ]
    })

    widget HealthWidget.new

    #script Hoard::Scripts::DebugRenderScript.new

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