module Hoard
  class Script
    attr_gtk

    attr_accessor :entity, :init_once_done

    def to_h
      {}.tap do |klass|
        instance_variables.reject { _1 == :@entity || _1 == :@args }.each do |k|
          klass[k.to_s[1..-1].to_sym] = instance_variable_get(k)
        end
      end
    end

    def serialize
      to_h
    end

    def to_s
      serialize.to_s
    end

    def get_save_data
      raise StandardError.new("get_save_data must be called on the server") unless server?
      raise StandardError.new("get_save_data can only be called on entities owned by a user") unless local?
      json = args.gtk.read_file("saves/#{self.class.name}.dat") || "{}"
      Argonaut::JSON.parse(json, symbolize_keys: true)
    end

    def set_save_data(data)
      raise StandardError.new("set_save_data must be called on the server") unless server?
      raise StandardError.new("set_save_data can only be called on entities owned by a user") unless local?

      args.gtk.write_file "saves/#{self.class.name}.dat", data.to_json
    end

    def user 
      entity&.user
    end

    def update; end
    def post_update; end
    def pre_update; end
    def on_pre_step_x; end
    def on_pre_step_y; end
    def init; end
    def on_collision(entity); end

    def client_update; end 
    def local_update; end

    def client_post_update; end 
    def client_pre_update; end
    def local_post_update; end
    def local_pre_update; end

    # future stuff
    def client_init; end
    def local_init; end
    def send_to_local(method_name, *args)
      if server? && client? 
        send(method_name, *args)
      end
    end
    def send_to_server(method_name, *args)
      if server? && client?
        send(method_name, *args)
      end
    end
    def server?() = entity&.server?
    def client?() = entity&.client?
    def local?() = entity&.local?
    def wait; end
  end
end
