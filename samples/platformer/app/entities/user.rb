class User < Hoard::User 
    script CoinsScript.new
    widget CoinsWidget.new
    script Hoard::Scripts::UserQuestsScript.new
    widget Hoard::Widgets::QuestsWidget.new

    script Hoard::Scripts::AudioScript.new(:coin_pickup, {
        files: [
            "samples/platformer/sounds/effects/handleCoins.ogg",
            "samples/platformer/sounds/effects/handleCoins2.ogg",
        ],
        overlap: true
    })

    script Hoard::Scripts::NotificationsScript.new

    script Hoard::Scripts::QuestScript.new(
        id: "collect_coins",
        name: "Collect Coins",
        description: "Collect 3 coins",
        image_url: "samples/platformer/images/quest_coin.png",
        asset: "coin",
        item: "coin",
        default_active: true,
        prerequisite: nil,
        required_completions: 3,
        index: 0,
        score: 10,
        track_by_default: true,
        daily: false
    )
end