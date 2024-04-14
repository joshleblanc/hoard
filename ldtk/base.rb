def make_key(ivar)
    key = ivar.to_s.split("_").map do |part| 
        "#{part[0].upcase}#{part[1..-1].downcase}"
    end.join

    "#{key[0].downcase}#{key[1..-1]}"
end

module Hoard
    module Ldtk
        class Base 
            attr :parent

            class << self 
                attr_reader :imports, :mappings

                def imports(*args, **mappings)
                    @imports = args
                    @mappings = mappings
        
                    attr *args, *mappings.keys
                end
        
                def import(json, parent = nil)
                    return unless json

                    new.tap do |c|
                        puts "Importing #{c.class.name}"
                        c.parent = parent
                        Array(c.imports).each do |ivar|
                            key = make_key(ivar)
                            value = json[key] || json["__#{key}"]

                            fixed_value = if value.is_a? Array 
                                value.map do |el|          
                                    if el.is_a? Hash 
                                        new_value = {}
                                        el.each do |k, v|
                                            new_value[k.to_sym] = v
                                        end
                                        new_value
                                    else
                                        el
                                    end
                                end
                            elsif value.is_a? Hash
                                new_value = {}
                                value.each do |k, v|
                                    new_value[k.to_sym] = v
                                end
                                new_value
                            else 
                                value
                            end
        
                            c.instance_variable_set("@#{ivar}".to_sym, fixed_value)
                        end
        
                        Array(c.mappings).each do |ivar, type|
                            key = make_key(ivar)
                            data = json[key] || json["__#{key}"]
        
                            next unless data
        
                            value = if type.is_a? Array 
                                klass = type.first
                                data.map do |datum|
                                    klass.import(datum, c)
                                end
                            else 
                                type.import(data, c)
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

            def root 
                @root ||= if @parent.nil? 
                    self
                else
                    @parent.root
                end
            end

            def to_s
                str = "" 
                imports.each do |import|
                    str << "#{import}: #{self.send(import)}, "
                end

                str
            end
        end
    end 
end