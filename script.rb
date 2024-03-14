module Hoard 
    class Script 
        attr_gtk 

        attr_accessor :entity

        def update; end 
        def post_update; end 
        def pre_update; end 
        def on_pre_step_x; end 
        def on_pre_step_y; end
        def init; end
        def on_collision(entity); end
    end
end