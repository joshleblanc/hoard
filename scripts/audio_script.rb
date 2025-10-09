module Hoard
    module Scripts
        class AudioScript < Script
            attr_reader :name, :files

            def initialize(name, files:)
                @name = name
                @files = files
            end

            def play_audio(name) 
                return unless name == @name

                return if args.audio[name]

                #p "Playing #{files.sample}"
                args.audio[name] = {
                    input: files.sample
                }
            end
        end
    end
end