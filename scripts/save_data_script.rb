module Hoard
  module Scripts
    class SaveDataScript < Script
      attr_reader :save_data

      def init
        return @save_data if @save_data
        json = args.gtk.read_file(path) || "{}"
        @save_data = Argonaut::JSON.parse(json, symbolize_keys: true)
      end

      def save(what)
        what.each do |k, v|
          save_data[k] = v
        end
        commit!
      end

      def id
        entity.ldtk_entity_script.id
      end

      def path
        "saves/#{id}.dat"
      end

      def on_shutdown
        commit!
        puts_immediately "shutdown"
      end

      def commit!
        args.gtk.write_file path, save_data.to_json
      end
    end
  end
end
