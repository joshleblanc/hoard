module Hoard
    module Scripts
        class DocumentStoreScript < Hoard::Script
        attr_accessor :data, :id, :use_versions, :version
    
        # future stuff 🙃
        # self.properties = [
        #   { name: :id, type: :string, default: 'default' },
        #   { name: :use_versions, type: :boolean, default: false },
        #   { name: :version, type: :number, default: 1, visible_if: ->(p) { p.use_versions } }
        # ]
    
        def initialize(id: "default", use_versions: false, version: 1)
            @id = id
            @use_versions = use_versions
            @version = version
        end
    
        def init
            @data = {}
        end
    
        # holdover from crayta
        def wait_for_data; end
    
        # the futuuuuure
        def client_init
            @data ||= {}
        end
    
        def init_save_data(data)
            self.data = data
        end
    
        def init_save_data_part(key, value)
            self.data ||= {}
            self.data[key] = value
        end
    
        def uuid
            $gtk.create_uuid
        end
    
        def find(query = {}, projection = nil)
            query(query, projection)
        end
    
        def find_one(query = {}, projection = nil)
            query_one(query, projection)
        end
    
        def insert_one(doc)
            id = doc[:_id] || uuid
            doc[:_id] = id
    
            if server?
            puts "(Server) Inserting one: #{id}"
            server_insert_one(id, doc)
            send_to_local(:local_insert_one, id, doc)
            else
            puts "(Local) Inserting one: #{id}"
            local_insert_one(id, doc)
            send_to_server(:server_insert_one, id, doc)
            end
    
            persist_data
            broadcast_to_scripts(:on_record_inserted, properties.id, doc)
            entity.send_to_scripts(:on_my_record_inserted, properties.id, doc)
    
            doc
        end
    
        def server_insert_one(id, doc)
            puts "Server insert one #{id} #{doc}"
            @data[id] = doc
        end
    
        def local_insert_one(id, doc)
            puts "Local Insert One #{id} #{doc}"
            @data[id] = doc
        end
    
        def insert_many(docs)
            docs.each { |doc| insert_one(doc) }
            docs
        end
    
        def update_many(query, operators, options = {})
            records = query(query)
            new_records = records.map { |record| update_record(record, query, operators, options) }
            persist_data
            new_records
        end
    
        def update_one(query, operators, options = {})
            record = query_one(query)
            return nil unless record || options[:upsert]
    
            record = update_record(record, query, operators, options)
            persist_data
            record
        end
    
        def server_update_one(id, record)
            @data[id] = record
        end
    
        def local_update_one(id, record)
            return unless @data
            @data[id] = record
        end
    
        def delete_one(query)
            record = query_one(query)
            return unless record
    
            process_delete(record)
            persist_data
            record
        end
    
        def process_delete(record)
            if server?
            server_delete_one(record[:_id])
            send_to_local(:local_delete_one, record[:_id])
            else
            local_delete_one(record[:_id])
            send_to_server(:server_delete_one, record[:_id])
            end
    
            broadcast_to_scripts(:on_record_deleted, properties.id, record)
            entity.send_to_scripts(:on_my_record_deleted, properties.id, record)
        end
    
        def local_delete_one(id)
            @data.delete(id)
        end
    
        def server_delete_one(id)
            @data.delete(id)
        end
    
        def delete_many(query)
            records = query(query)
            records.each { |record| process_delete(record) }
            persist_data
            records
        end
    
        private
    
        def query(query = {}, projection = nil)
            return [@data[query[:_id]]] if query[:_id] && @data[query[:_id]]
    
            results = if query.empty?
                @data.values
            else
                @data.values.select { |record| validate_record(query, record) }
            end
    
            project_results(results, projection)
        end
    
        def query_one(query = {}, projection = nil)
            return @data[query[:_id]] if query[:_id]
    
            record = if query.empty?
                @data.values.first
            else
                @data.values.find { |record| validate_record(query, record) }
            end
    
            project_record(record, projection)
        end
    
        def validate_record(query, record)
            return false unless record
    
            query.all? do |field, value|
            if value.is_a?(Hash)
                process_selectors(record, field, value)
            else
                get_nested_value(record, field) == value
            end
            end
        end
    
        def get_nested_value(record, field)
            field.to_s.split(".").inject(record) { |memo, part| memo && memo[part.to_sym] }
        end
    
        def process_selectors(record, field, selectors)
            selectors.all? do |selector, value|
            case selector
            when :$eq then get_nested_value(record, field) == value
            when :$gt then get_nested_value(record, field) > value
            when :$lt then get_nested_value(record, field) < value
            when :$gte then get_nested_value(record, field) >= value
            when :$lte then get_nested_value(record, field) <= value
            when :$ne then get_nested_value(record, field) != value
            when :$in then value.include?(get_nested_value(record, field))
            when :$nin then !value.include?(get_nested_value(record, field))
            end
            end
        end
    
        def update_record(record, query, operators, options)
            record ||= {} if options[:upsert]
            return unless record
    
            operators.each do |operator, fields|
            fields.each do |field, value|
                case operator
                when :$set then set_nested_value(record, field, value)
                when :$inc
                current = get_nested_value(record, field) || 0
                set_nested_value(record, field, current + value)
                when :$unset then unset_nested_value(record, field)
                end
            end
            end
    
            record[:_id] ||= uuid if options[:upsert]
    
            if server?
            server_update_one(record[:_id], record)
            send_to_local(:local_update_one, record[:_id], record)
            else
            local_update_one(record[:_id], record)
            send_to_server(:server_update_one, record[:_id], record)
            end
    
            broadcast_to_scripts(:on_record_updated, properties.id, record)
            entity.send_to_scripts(:on_my_record_updated, properties.id, record)
    
            record
        end
    
        def set_nested_value(record, field, value)
            parts = field.to_s.split(".")
            target = parts[0..-2].inject(record) { |memo, part| memo[part.to_sym] ||= {} }
            target[parts.last.to_sym] = value
        end
    
        def unset_nested_value(record, field)
            parts = field.to_s.split(".")
            target = parts[0..-2].inject(record) { |memo, part| memo[part.to_sym] }
            target&.delete(parts.last.to_sym)
        end
    
        def project_results(results, projection)
            return results unless projection
    
            results.map { |record| project_record(record, projection) }
        end
    
        def project_record(record, projection)
            return record unless projection && record
    
            result = {}
            projection.each do |field, include|
            result[field] = record[field] if include
            end
            result
        end
    
        def persist_data
            if !server?
            send_to_server(:persist_data)
            return
            end
    
            entity.document_stores_script.persist_data
        end
    
        def on_user_logout(user)
            return unless user == entity
            persist_data
        end
        end
    end
end