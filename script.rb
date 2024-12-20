module Hoard 
    class Script 
        attr_gtk 

        attr_accessor :entity

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
            json = args.gtk.read_file("saves/#{self.class.name}.dat") || "{}"
            Argonaut::JSON.parse(json, symbolize_keys: true)
        end

        def set_save_data(data)
            args.gtk.write_file "saves/#{self.class.name}.dat", data.to_json
        end

        def update; end 
        def post_update; end 
        def pre_update; end 
        def on_pre_step_x; end 
        def on_pre_step_y; end
        def init; end
        def on_collision(entity); end

        # future stuff
        def client_init; end 
        def send_to_local(method_name, *args); end
        def send_to_server(method_name, *args); end
        def server?()= true
        def client?()= false
        def wait; end
    end
end