class Worm < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    script Hoard::Scripts::MoveToDestinationScript.new
    script Hoard::Scripts::CollisionDamageScript.new
    script Hoard::Scripts::AnimationScript.new(:worm, {
        files: [
            "samples/platformer/sprites/enemies/worm_ring_move_a.png",
            "samples/platformer/sprites/enemies/worm_ring_move_b.png",
        ],
    })

    def init 
        send_to_scripts(:play_animation, :worm, true)
    end
end