class Coin < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    #script Hoard::Scripts::DebugRenderScript.new
    script Hoard::Scripts::PickupScript.new(persistant: false)
    script Hoard::Scripts::InventorySpecScript.new(
        icon: nil,
        name: "Coin"
    )
    script Hoard::Scripts::AnimationScript.new(
        :coin,
        path: "samples/platformer/sprites/spritesheet-tiles-default.png",
        x: 15 * 64,
        y: 7 * 64,
        frames: 2,
        tile_w: 64,
        tile_h: 64,
        w: 64,
        h: 64,
        horizontal_frames: false
    )

    def init 
        send_to_scripts(:play_animation, :coin, true)
    end
end