class Worm < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    script Hoard::Scripts::MoveToDestinationScript.new
end