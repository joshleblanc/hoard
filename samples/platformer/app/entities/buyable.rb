class Buyable < Hoard::Entity 
    script Hoard::Scripts::LdtkEntityScript.new
    script Hoard::Scripts::LabelScript.new
    script BuyableScript.new
    script Hoard::Scripts::PromptScript.new(prompt: "Press E to buy!")
end