class User < Hoard::User 
    script CoinsScript.new
    widget CoinsWidget.new

    script Hoard::Scripts::AudioScript.new(:coin_pickup, {
        files: [
            "samples/platformer/sounds/effects/handleCoins.ogg",
            "samples/platformer/sounds/effects/handleCoins2.ogg",
        ],
        overlap: true
    })
end