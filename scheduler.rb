module Hoard 
    class Scheduler
        def initialize(tick_count = 0, blk)
            @blk = blk
            @tick_count = $args.state.tick_count + tick_count

            @run = false

            @waits = 0
        end

        def wait(frames = 1, &blk)
            @waits += frames
            Scheduler.schedule(@waits, &blk) if blk
        end

        def tick 
            return if done?
            
            @blk.call(self, @blk)

            @run = true
        end

        def ready?
            $args.state.tick_count >= @tick_count
        end

        def run?
            @run
        end

        def done?
            run? && $args.state.tick_count > @tick_count
        end

        def self.schedule(frame = 0, &blk)
            @schedules ||= []
            @schedules << new(frame, blk)
        end

        def self.tick
            @schedules ||= []

            @schedules.select(&:ready?).each(&:tick)
            @schedules.reject!(&:done?)
        end
    end
end