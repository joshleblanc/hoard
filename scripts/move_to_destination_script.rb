module Hoard 
    module Scripts 
        class MoveToDestinationScript < Hoard::Script 
            attr :destination, :loop
            
            def init 
                @origin_x = entity.x
                @origin_y = entity.y
                @destination_x = destination.cx * Hoard.config.game_class::GRID
                @destination_y = destination.cy * Hoard.config.game_class::GRID

                @target_x = @destination_x
                @target_y = @destination_y

                @looping = false
            end

            def loop? 
                !!self.loop
            end

            def distance_threshold
                if @looping
                    1
                else
                    entity.w + 1
                    
                end
            end

            def update 
                args.outputs.debug << entity.w.to_s
                dx = @target_x - entity.x
                dy = @target_y - entity.y
                norm = Geometry.vec2_normalize({ x: dx, y: dy})
                entity.v_base.dx = (entity.v_base.dx + norm.x.sign) * 0.025
                #entity.v_base.dy = (entity.v_base.dy + norm.y) * 0.085

                distance = Geometry.distance({ x: entity.x, y: entity.y }, { x: @target_x, y: @target_y })
                args.outputs.debug << distance.to_s
                if distance <= distance_threshold && loop?
                    entity.v_base.dx = 0
                    entity.v_base.dy = 0
                    entity.dir = -entity.dir

                    if @looping 
                        @looping = false
                        @target_x = @destination_x
                        @target_y = @destination_y
                    else 
                        @looping = true
                        @target_x = @origin_x
                        @target_y = @origin_y
                    end
                end
            end
        end
    end
end