class Coin < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    #script Hoard::Scripts::DebugRenderScript.new
    script Hoard::Scripts::PickupScript.new
    script Hoard::Scripts::InventorySpecScript.new(
        icon: nil,
        name: "Coin"
    )
end