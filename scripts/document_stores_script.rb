module Hoard 
    module Scripts
        class DocumentStoresScript < Hoard::Script
          attr_accessor :stores, :root, :ready
      
          def init
            init_dbs
          end
      
          def local_init
            init_dbs
          end
      
          def clear
            root&.each_key do |key|
              self[key].delete_many
            end
          end
      
          def init_dbs
            @stores = []
            entity.find_scripts(Scripts::DocumentStoreScript).each do |store|
              self[store.id] = store
              @stores << store
              
              if server?
                @root ||= get_save_data
                
                id = store.id
                
                if store.use_versions
                  @root[id] = nil
                  (1...store.version).each do |i|
                    @root["#{id}_#{i}"] = nil
                  end
                  id = "#{id}_#{store.version}"
                end
                
                @root[id] ||= {}
                
                data = @root[id]
                
                store.init_save_data(data)
                
                data.each do |k, v|
                  store.send_to_local("init_save_data_part", k, v)
                end
                
                puts "Initialized: #{store.id} #{store.data}"
              end
            end
            
            @ready = true
          end
      
          def persist_data
            unless server?
              send_to_server("persist_data")
              return
            end
            set_save_data(@root)
          end
      
          def get_db(db)
            init_dbs unless @ready
            self[db]
          end
      
          def use_db(db, &block)
            schedule do
              wait_for_ready
              self[db].wait_for_data
              
              block.call(self[db])
            end
          end
      
          def wait_for_ready
            wait until @ready
          end
      
          # Singleton proxy methods  
      
          def wait_for_data
            proxy_method(:wait_for_data)
          end
      
          def find(*args)
            proxy_method(:find, *args)
          end
      
          def find_one(*args)
            proxy_method(:find_one, *args)
          end
      
          def insert_one(*args)
            proxy_method(:insert_one, *args)
          end
      
          def insert_many(*args)
            proxy_method(:insert_many, *args)
          end
      
          def update_many(*args)
            proxy_method(:update_many, *args)
          end
      
          def update_one(*args)
            proxy_method(:update_one, *args)
          end
      
          def replace_one(*args)
            proxy_method(:replace_one, *args)
          end
      
          def delete_one(*args)
            proxy_method(:delete_one, *args)
          end
      
          def delete_many(*args)
            proxy_method(:delete_many, *args)
          end
      
          private
      
          def []=(key, value)
            sanitized_key = sanitize_key(key)
            instance_variable_set("@#{sanitized_key}", value)
          end

          def [](key)
            sanitized_key = sanitize_key(key)
            instance_variable_get("@#{sanitized_key}")
          end

          def sanitize_key(key)
            # Convert hyphens to underscores for valid instance variable names
            key.to_s.tr('-', '_')
          end
      
          def proxy_method(method, *args)
            @stores.first&.send(method, *args)
          end
        end
      end
end