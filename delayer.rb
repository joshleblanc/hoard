module Hoard 
    class Delayer 
        class Task 
            attr :id, :t, :cb
            def initialize(id, t, cb)
                @id = id
                @t = t
                @cb = cb
            end

            def to_s 
                "#{t} #{cb}"
            end
        end

        attr :delays, :fps

        def initialize(fps)
            @fps = fps 
            @delays = []
        end

        def to_s 
            "Delayer(timers=#{@delays.map(&:t).join(",")})"
        end

        def destroyed?
            @delays == nil
        end

        def destroy!
            @delays = nil
        end

        def skip
            limit = delays.length + 100
            while @delays.length > 0 && (limit -= 1) > 0
                d = @delays.shift 
                d.cb.call
                d.cb = nil
            end
        end

        def cancel_everything!
            @delays = []
        end

        def has_id?(id)
            @delays.any? { |d| d.id == id }
        end

        def cancel_by_id(id)
            delay = @delays.find { |d| d.id == id }
            @delays.delete delay
        end

        def run_immediately(id)
            delay = @delays.find { |id| d.id == id }
            delay&.cb&.call
        end

        def cmp(a, b)
            if a.t < b.t 
                -1 
            elsif a.t > b.t 
                1
            else
                0
            end
        end

        def add_ms(id, cb, ms)
            @delays << Task.new(id, ms / 1000 * fps, cb)
            @delays.sort!(&method(:cmp))
        end

        def add_s(id, cb, sec)
            @delays << Task.new(id, sec * fps, cb)
            @delays.sort!(&method(:cmp))
        end

        def add_f(id, cb, frames)
            @delays << Task.new(id, frames, cb)
            @delays.sort!(&method(:cmp))
        end

        def any?
            !destroyed? && @delays.length > 0
        end

        def update(dt)
            @delays.each_with_index do |d, i|
                d.t -= dt
                if d.t <= 0
                    d.cb.call
                    if @delays == nil || @delays[i] == nil # can happen if the cb cancelled it
                        return
                    end
                    d.cb = nil
                end
            end

            @delays.reject! { |d| d.t <= 0 }
        end

    end
end