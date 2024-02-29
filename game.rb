module Hoard
    class Game 
        attr_gtk 

        attr :camera, :fx, :current_level, :hud, :slow_mos
        attr :cur_game_speed, :scroller


        def initialize
            @slow_mos = {}
            @cur_game_speed = 1

            @scroller = Layer.new(:scene)
            @camera = Camera.new
        end

        def start_level(level)
            @current_level = level
            @camera.center_on_target
            # destroy level and all spawned entities
        end

        ##
        # Start a cumulative slow-motion effect that will affect 'tmod' value in this Process
        # and all its children
        #
        # @param sec Realtime second duration of this slowmo
        # @param speed_factor Cumulative multiplier to this Process 'tmod'
        def add_slowmo(id, sec, speed_factor = 0.3)
            if slow_mos[id]
                s = slow_mos[id]
                s[:f] = speed_factor
                s[:t] = [s[:t], sec].max
            else 
                slow_mos[id] = {
                    id: id,
                    t: sec,
                    f: speed_factor
                }
            end
        end

        def update_slow_mos
            slow_mos.each do |k, v|
                v[:t] -= utmod * 1 / 60
                if v[:t] <= 0 
                    slow_mos.delete v[:id]
                end
            end

            target_game_speed = 1 
            slow_mos.each do |k, v|
                target_game_speed *= v[:f]
            end

            self.cur_game_speed = (target_game_speed - cur_game_speed) * (target_game_speed > cur_game_speed ? 0.2 : 0.6)

            if (cur_game_speed - target_game_speed).abs <= 0.001
                cur_game_speed = target_game_speed
            end
        end

        def stop_frame
            # ucd.setS("stopFrame", 4/60)
        end

        def pre_update 
            state.entities.each do |entity|
                entity.pre_update unless entity.destroyed?
            end
            @camera&.pre_update
        end

        def post_update 
            update_slow_mos

            #self.base_time_mul = (0.2 + 0.8 * cur_game_speed) * (ucd.has("stopFrame") ? 0.1 : 1)

            active_entities.each(&:post_update)
            @camera&.post_update

            render

            active_entities.each(&:final_update)
            @camera&.final_update

            garbage_collect_entities
        end

        def active_entities 
            state.entities.reject(&:destroyed?)
        end

        def garbage_collect_entities

        end

        def self.s 
            @@instance ||= new
        end

        def defaults 

        end

        def tick 
            defaults
            pre_update
            active_entities.each(&:update) 
            @camera&.update
            post_update
        end

        def render
            outputs[:scene].transient!

            if @current_level 
                outputs[:scene].sprites.push @current_level
            end

            outputs[:scene].sprites.push active_entities
            outputs.sprites << @scroller
            
        end
    end
end