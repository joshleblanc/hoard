module Hoard
    module Scripts
        class AudioScript < Script
            attr_reader :name, :files

            def initialize(name, files:, overlap: false)
                @name = name
                @files = files
                @overlap = overlap
                
            end

            def play_audio(name) 
                return unless name == @name

                return if args.audio[name]

                #p "Playing #{files.sample}"
                if @overlap 
                    args.outputs.sounds << files.sample
                else
                    args.audio[name] = {
                        input: files.sample
                    }
                end
                
            end
        end
    end
end