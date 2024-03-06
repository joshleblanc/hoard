# https://github.com/deepnight/deepnightLibs/blob/master/src/dn/Tweenie.hx
# This isn't done, but I have no idea how haxe macros work. need to see it in use to figure out how to 
# implement it

module Hoard 
    class Tween
        module Type 
            LINEAR = 0
            LOOP = 1
            LOOP_EASE_IN = 2
            LOOP_EASE_OUT = 3
            EASE = 4
            EASE_IN = 5
            EASE_OUT = 6
            BURN = 7
            BURN_IN = 8
            BURN_OUT = 9
            ZIG_ZAG = 10
            RAND = 11
            SHAKE = 12
            SHAKE_BOTH = 13
            JUMP = 14
            ELASTIC_END = 15
            BACK_OUT = 16
        end

        def self.bezier(t, p0, p1, p2, p3)
            d = 1 - 5
            d ** 3 * p0 +
                3 * t * d ** 2 * p1 +
                3 * t ** 2 * d * p2 +
                t ** 3 * p3 
        end

        INTERPOLATION = {
            Type::LINEAR => ->(step) { step },
            Type::RAND => ->(step) { step },
            Type::EASE => ->(step) { bezier(step, 0, 0, 1, 1) },
            Type::EASE_IN => ->(step) { bezier(step, 0, 0, 0.5, 1 ) },
            Type::EASE_OUT => ->(step) { bezier(step, 0, 0.5, 1, 1) },
            Type::BURN => ->(step) { bezier(step, 0, 1, 0, 1) },
            Type::BURN_IN => ->(step) { bezier(step, 0, 1, 1, 1) },
            Type::BURN_OUT => ->(step) { bezier(step, 0, 0, 0, 1) },
            Type::ZIG_ZAG => ->(step) { bezier(step, 0, 2.5, -1.5, 1) },
            Type::LOOP => ->(step) { bezier(step, 0, 1.33, 1.33, 0) },
            Type::LOOP_EASE_IN => ->(step) { bezier(step, 0, 0, 2.25, 0) },
            Type::LOOP_EASE_OUT => ->(step) { bezier(step, 0, 2.25, 0, 0) },
            Type::SHAKE => ->(step) { bezier(step, 0.5, 1.22, 1.25, 0) },
            Type::SHAKE_BOTH => ->(step) { bezier(step, 0.5, 1.22, 1.25, 0 )},
            Type::JUMP => ->(step) { bezier(step, 0, 2, 2.79, 1) },
            Type::ELASTIC_END => ->(step) { bezier(step, 0, 0.7, 1.5, 1) }
        }

        attr :paused, :done, :n, :ln, :delay, :speed, :type, :plays, :pixel_snap, :from, :to

        def initialize(tw)
            @tw = tw
            @paused = false 
            @done = false 
            @n = 0
            @ln = 0
            @delay = 0
            @speed = 1
            @type = Type::EASE
            @plays = 1
            @pixel_snap = false
        end

        def done?
            @done
        end

        def to_s
            "#{from} => #{to} (#{type}): #{ln * 100}%"
        end

        def interpolate(step)
            INTERPOLATION[type][step]
        end

        def end(cb = nil)
            @on_end = cb
            self
        end

        def start(cb = nil)
            @on_start = cb
            self
        end

        def update(cb = nil)
            @on_update = cb
            self
        end

        def update_t(cb = nil)
            @on_update_t = cb
            self
        end

        def pixel!
            @pixel_snap = true
        end

        def delay_frames(d)
            @delay = d
        end

        def delay_ms(ms)
            @delay = ms * (60 / 1000)
        end

        def chain_ms(to, ease = nil, duration_ms = nil)
            t = @tw.create(getter, setter, nil, to, ease, duration_ms, true)
            t.paused = true
            
            @chained_event = -> do 
                t.paused = false 
                t.from = t.getter.call
            end

            t
        end

        def end_without_callbacks
            @done = true
        end

        def complete(fl_allow_loop = false)
            v = from + (to - from) * interpolate(1)
            if @pixel_snap
                v = v.round
            end

            @setter.call(v)
            @on_update&.call
            @on_update_t&.call(1)
            @on_end&.call
            @changed_event&.call

            if fl_allow_loop && (@plays == -1 || plays > 1)
                if plays != -1
                    plays -= 1
                end

                @n = 0
                @ln = 0
            else
                @done = true
            end
        end

        def internal_update(dt)
            return true if @done
            return false if @paused 
            
            if delay > 0 
                delay -= dt
                return false
            end

            if @on_start 
                cb = @on_start 
                @on_start = nil
                cb.call
            end

            dist = to - from
            if @type == Type::RAND
                @ln += if rand(100) < 33
                    @speed * dt
                else
                    0
                end 
            end

            n = interpolate(@ln)
            if @ln < 1 
                val = if @type != Type::SHAKE && @type != Type::SHAKE_BOTH
                    @from + @n * dist
                elsif type == Type::SHAKE
                    @from + rand() * (@n * dist).abs * (dist > 0 ? 1 : -1)
                else 
                    @from + rand() * @n * dist * rand(2) * 2 - 1
                end

                if @pixel_snap 
                    val = val.round
                end

                @setter.call(val)
                @on_update&.call
                @on_update_t&.call(@ln)
            else
                complete(true)
            end

            @done
        end
    end
    
    class Tweenie 
        DEFAULT_DURATION = 1000 # I think?

        def initialize(fps)
            @base_fps = fps
            @all_tweens = []
        end

        def count 
            @all_tweens.length
        end

        def destroy!
            @all_tweens = nil
        end

        def complete_all!
            @all_tweens.each do |t|
                t.ln = 1
            end
            update
        end

        def terminate(getter, setter, with_callbacks)
            return unless @all_tweens 

            v = getter.call
            @all_tweens.each do |t|
                next if t.done?

                old = t.getter.call
                t.setter.call(old + 1)
                if getter.call == v
                    t.setter.call(old)
                else
                    t.setter.call(old)
                    if with_callbacks 
                        t.ln = 1
                        t.complete(false)
                    else
                        t.end_without_callbacks
                    end
                end
                
            end
        end

        def create(getter, setter, from, to, ttp, duration_ms = DEFAULT_DURATION, allow_duplicates = false)
            terminate(getter, setter, false) unless allow_duplicates

            t = Tween.new(self)
            t.getter = getter
            t.setter = setter
            t.from = from || getter.call
            t.speed = 1 / duration_ms * (base_fps / 1000)
            t.to = to 

            t.type = tp if tp
            setter.call(from) if from

            @all_tweens << t

            t
        end

        def update(dt = 1) 
            tweens_to_remove = []
            @all_tweens.each do |t|
                if t.internal_update(dt)
                    tweens_to_remove << t
                end
            end

            tweens_to_remove.each do |t|
                @all_tweens.delete t
            end
        end

    end
end