class BuyableScript < Hoard::Script 
    attr :price 
    attr :item

    def update 
        debug "#{item} #{price}"
    end
end