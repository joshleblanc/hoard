# https://github.com/deepnight/deepnightLibs/blob/master/src/dn/Cooldown.hx

module Hoard 
    class Cooldown 
        DEFAULT_COUNT_LIMIT = 512
        BASE_FPS = 60

        attr :cds, :base_fps, :fast_check

        def initialize(fps = BASE_FPS, max_size = DEFAULT_COUNT_LIMIT)
            @base_fps = fps
            
            change_max_size_and_reset(max_size)
        end

        def change_max_size_and_reset(new_max_size)
            @cds = RecyclablePool.new(new_max_size, CdInst)
            reset
        end

        def reset 
            @cds.free_all
            @fast_check = {}
        end
        
        def destroy 
            dispose
        end

        def count 
            @cds.allocated
        end

        def dispose 
            @cds.dispose(nil)
            @cds = nil
            @fast_check = nil
        end

        def sec_to_frames(s)
            s * BASE_FPS
        end

        def ms_to_frames(ms)
            (ms * BASE_FPS) / 1000.0
        end

        def set(...)
            set_s(...)
        end

        def set_s(key, seconds, allow_lower: true, on_complete: nil)
            set_f(key, sec_to_frames(seconds), allow_lower: allow_lower, on_complete: on_complete)
        end

        def get_f(k)
            cd = get_cd_object(k)
            cd&.frames
        end

        def get_initial_value_f(k)
            cd = get_cd_object(k)
            cd&.initial
        end

        def get_ratio(k)
            max = get_initial_value_f(k)
            max <= 0 ? 0 : get_f(k) / max
        end

        def on_complete(k, once_cb)
            cd = get_cd_object(k)
            if cd 
                cd.on_complete_once = once_cb
            end
        end

        def set_f(k, frames, allow_lower: true, on_complete: nil)
            cur = get_cd_object(k)

            return if cur && frames < cur.frames && !allow_lower

            if frames <= 0
                unset_cd_inst(cur) if cur
            else 
                fast_check[k] = true
                if cur 
                    cur.frames = frames 
                    cur.initial = frames
                else 
                    cd = cds.alloc
                    cd.set(k, frames)
                end
            end

            if on_complete
                if frames <= 0 
                    on_complete.call
                else
                    self.on_complete(k, on_complete)
                end
            end
        end

        def unset(k)
            cds.allocated.times do |i|
                if cds.get(i).key == k 
                    unset_index(i)
                    return
                end
            end
        end

        def has(k)
            fast_check[k]
        end

        def has_set_f(k, frames)
            if has(k) 
                true
            else 
                set_f(k, frames)
                false
            end
        end

        def get_cd_object(k)
            cds.find { |cd| cd.key == k }
        end

        def unset_cd_inst(cd)
            fast_check.delete(cd.key)
            cds.free_element(cd)
        end

        def unset_index(idx)
            fast_check.delete cds.get(idx).key
            cds.free_index idx
        end

        def update(tmod = 1)
            cds.allocated.times do |idx|
                cd = cds.get(idx)
                b = cd.frames
                cd.frames -= tmod
                
                if cd.frames <= 0 
                    cb = cd.on_complete_once 
                    unset_index(idx)
                    cb.call if cb.respond_to? :call 
                end
            end
        end
    end

    class CdInst 
        attr :key, :frames, :initial, :on_complete_once
    
        def set(key, frames)
            self.key = key
            self.frames = frames
            self.initial = frames
        end

        def recycle 
            self.on_complete_once = false
        end

        def remaining_ratio
            if initial == 0 
                0
            else
                frames / initial
            end
        end

        def progress_ratio
            if initial == 0
                0
            else 
                1 - remaining_ratio
            end
        end
    end
end