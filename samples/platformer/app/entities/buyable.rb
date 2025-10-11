class Buyable < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    script BuyableScript.new
    script Hoard::Scripts::PromptScript.new(prompt: "Press E to buy!")
    script Hoard::Scripts::LabelScript.new
end