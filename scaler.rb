module Hoard
    class Scaler
        class << self 
            def viewport_width
                1280
            end

            def viewport_height
                720
            end

            def best_fit_f(wid_px, hei_px = nil, context_wid = nil, context_hei = nil, allow_below_one = false)
                sx = (context_wid || viewport_width) / wid_px
                sy = (context_hei || viewport_height) / (hei_px || wid_px)
                
                if allow_below_one
                    [sx,sy].min
                else
                    [1, [sx, sy].min].max
                end
            end

            def best_fit_i(wid_px, hei_px = nil, context_wid = nil, context_hei = nil)
                best_fit_f(wid_px, hei_px, context_wid, context_hei).floor
            end

            def best_fit_aspect_ratio_wid_i(wid_px, aspect_ratio = nil, context_wid = nil, context_hei = nil)
                best_fit_f(wid_px, wid_px / aspect_ratio, context_wid, context_hei).floor
            end

            def fill_f(wid_px, hei_px = nil, context_wid = nil, context_hei = nil, integer_scale = true)
                sx = (context_wid || viewport_width) / wid_px
                sy = (context_hei || viewport_height) / (hei_px || wid_px)

                if integer_scale 
                    sx = sx.floor
                    sy = sy.floor
                end

                [1, sx, sy].max
            end
        end
    end
end
