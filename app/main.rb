$gtk.disable_controller_config!

require "hoard"
require "ldtk/root"

Hoard::Process.server = true
Hoard::Process.client = true

sample = GTK.cli_arguments.sample

require "samples/#{sample}/app/main.rb"