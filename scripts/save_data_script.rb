module Hoard
  module Scripts
    class SaveDataScript < Script
      attr_reader :data, :reset

      def initialize(reset: false)
        @reset = reset
      end

      def reset?
        !!self.reset
      end

      def init
        if reset? 
          set_data {}
        else 
          set_data get_save_data
        end
      end

      def local_set_data(data)
        @data = data
      end

      def server_set_data(data)
        @data = data 
        set_save_data(data)
      end

      def set_data(data)
        if server? 
          server_set_data(data)
          send_to_local(:local_set_data, data)
        else 
          local_set_data(data)
          send_to_server(:server_set_data, data)
        end
      end

      def save_data(key, value)
        @data[key] = value
        set_data(self.data)
      end

      def get_data(key)
        @data[key]
      end
    end
  end
end
