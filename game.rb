module Hoard
    class Game < Process
        attr_gtk 

        attr :camera, :fx, :current_level, :hud, :slow_mos
        attr :cur_game_speed, :scroller, :fx

        class << self 
            @grid = 16

            attr :grid
        end

        def initialize
            super

            @slow_mos = {}
            @cur_game_speed = 1

            @scroller = Layer.new(:scene)
            @camera = Camera.new

            @fx = Fx.new
        end

        def start_level(level)
            destroy_all_children
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

        def post_update
            update_slow_mos

            self.base_time_mul = (0.2 + 0.8 * cur_game_speed) * (ucd.has("stopFrame") ? 0.1 : 1)

            render
        end

        def self.s 
            @@instance ||= new
        end

        def tick
            Process.update_all(utmod)
            Scheduler.tick
        end

        def pre_update 
            args.outputs[:ui].transient!
            args.outputs[:scene].transient!
        end

        def render
            if @current_level 
                args.outputs[:scene].sprites.push @current_level
            end

            args.outputs.sprites << @scroller
            args.outputs.sprites << { x: 0, y: 0, h: 720, w: 1280, path: :ui}
        end
    end
end