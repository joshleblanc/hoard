module Hoard
  module Scripts
    class NotificationsScript < Script
      TRANSITION_TIME = 35
      LIFESPAN = 100

      def initialize
        @notifications = []
        @queue = []
        @cd = Hoard::Cooldown.new

        notify_slowly
      end

      def add_notification(icon, title)
        obj = {
          icon: icon,
          title: title,
        }
        @queue.push(obj)
      end

      def notify_slowly
        if @queue.size > 0
          item = @queue.pop
          delay = @notifications.empty? ? 0 : 0.12
          @cd.set_s("add_to_queue", delay, on_complete: -> do
                                             item.added_at = state.tick_count
                                             @notifications << item

                                             @cd.set_s(@notifications.size.to_s, 5)
                                             notify_slowly
                                           end)
        else
          @cd.set_s("wait", 0.1, on_complete: -> do
                                   notify_slowly
                                 end)
        end
      end

      def update
        @cd.update

        tick_count = state.tick_count
        @notifications.reject! do |notification|
          diff = tick_count - notification.added_at
          diff > (TRANSITION_TIME * 2) + LIFESPAN
        end
      end

      def fit_to_width(what, width)
        parts = what.split(" ")
        current = ""
        result = []
        parts.each do |part|
          tmp = current.dup
          current << " " if current.length > 0
          current << part
          w, _ = gtk.calcstringbox(current, 1)
          if w >= width
            result << tmp
            current = part
          end
        end

        result + [current]
      end

      def post_update
        @notifications.each_with_index do |item, i|
          tick_count = state.tick_count
          left = if tick_count - item.added_at > LIFESPAN
              easing.ease(
                item.added_at + LIFESPAN + TRANSITION_TIME,
                state.tick_count,
                TRANSITION_TIME,
                :flip, :quad
              )
            else
              easing.ease(
                item.added_at,
                state.tick_count,
                TRANSITION_TIME,
                :flip, :quad, :flip
              )
            end

          l = layout.rect(row: 11 - i, col: (25 - (6 * left)), w: 5, h: 1)

          outputs[:ui].solids << l.merge({
            r: 0, g: 0, b: 0, a: 125,
          })

          outputs[:ui].borders << l.merge({
            r: 0, g: 0, b: 0, a: 255,
          })

          x_offset = 24
          if item.icon.path
            x_offset += l.w / 5
            outputs[:ui].sprites << l.merge({
              path: item.icon.path,
              tile_x: item.icon.tile_x,
              tile_y: item.icon.tile_y,
              tile_w: item.icon.tile_w,
              tile_h: item.icon.tile_h,
              w: l.w / 5,
            })
          end

          title = fit_to_width(item.title, l.w - x_offset)

          title.each_with_index do |title_part, ind|
            _, h = gtk.calcstringbox(title_part, 1)
            outputs[:ui].labels << l.merge({
              x: l.x + x_offset,
              y: l.y + (24 * title.count) - (ind * h),
              text: title_part,
              r: 255, g: 255, b: 255,
              font_size: -1,
            })
          end
        end
      end
    end
  end
end
