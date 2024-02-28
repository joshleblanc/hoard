def make_key(ivar)
    key = ivar.to_s.split("_").map do |part| 
        "#{part[0].upcase}#{part[1..-1].downcase}"
    end.join

    "#{key[0].downcase}#{key[1..-1]}"
end

module Hoard
    module Ldtk
        class Base 
            class << self 
                attr_reader :imports, :mappings

                def imports(*args, **mappings)
                    @imports = args
                    @mappings = mappings
        
                    attr *args, *mappings.keys
                end
        
                def import(json)
                    return unless json


                    new.tap do |c|
                        c.imports.each do |ivar|
                            key = make_key(ivar)
                            value = json[key] || json["__#{key}"]
        
                            c.instance_variable_set("@#{ivar}".to_sym, value)
                        end
        
                        c.mappings.each do |ivar, type|
                            key = make_key(ivar)
                            data = json[key] || json["__#{key}"]
        
                            next unless data
        
                            value = if type.is_a? Array 
                                klass = type.first
                                data.map(&klass.method(:import))
                            else 
                                type.import(data)
                            end
                            
                            c.instance_variable_set("@#{ivar}".to_sym, value)
                        end
                    end
                end
            end

            def imports 
                self.class.instance_variable_get(:@imports)  
            end

            def mappings 
                self.class.instance_variable_get(:@mappings)
            end
        end
    end 
end