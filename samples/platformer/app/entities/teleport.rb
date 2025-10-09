class Teleport < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    script TeleportScript.new
    script Hoard::Scripts::PromptScript.new(prompt: "Press E to interact")
end