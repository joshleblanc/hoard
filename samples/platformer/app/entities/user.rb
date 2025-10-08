class User < Hoard::User 
    script Scripts::CoinsScript.new
    widget Widgets::CoinsWidget.new
end