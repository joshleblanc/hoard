$gtk.disable_controller_config!

sample = GTK.cli_arguments["--sample"]

require "samples/#{sample}/app/main.rb"