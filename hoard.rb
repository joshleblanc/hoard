require_relative "utils"
require_relative "serializable"
require_relative "widgetable"
require_relative "ui/colors"
require_relative "ui/element_pool"
require_relative "ui/element"
require_relative "ui/window"
require_relative "ui/text"
require_relative "ui/col"
require_relative "ui/row"
require_relative "ui/button"
require_relative "ui/image"
require_relative "widget"
require_relative "scriptable"
require_relative "script"
require_relative "scripts/move_to_destination_script"
require_relative "scripts/gravity_script"
require_relative "scripts/health_script"
require_relative "scripts/animation_script"
require_relative "scripts/jump_script"
require_relative "scripts/ldtk_entity_script"
require_relative "scripts/prompt_script"
require_relative "scripts/progress_bar_script"
require_relative "scripts/inventory_spec_script"
require_relative "scripts/notifications_script"
require_relative "scripts/inventory_script"
require_relative "scripts/pickup_script"
require_relative "scripts/debug_render_script"
require_relative "scripts/save_data_script"
require_relative "scripts/disable_controls_script"
require_relative "scripts/shop_script"
require_relative "scripts/loot_locker_currency_gift_script"
require_relative "scripts/move_to_neighbour_script"
require_relative "scripts/platformer_controls_script"
require_relative "scripts/platformer_player_script"
require_relative "scripts/effect_script"
require_relative "scripts/document_stores_script"
require_relative "scripts/document_store_script"
require_relative "scripts/audio_script"
require_relative "widgets/progress_bar_widget"
require_relative "process"
require_relative "delayer"
require_relative "tweenie"
require_relative "fx"
require_relative "const"
require_relative "recyclable_pool"
require_relative "phys/velocity"
require_relative "phys/velocity_array"
require_relative "l_point"
require_relative "layer"
require_relative "scaler"
require_relative "cooldown"
require_relative "camera"
require_relative "entity"
require_relative "game"
require_relative "stat"
require_relative "scheduler"
require_relative "user"

module Hoard 
    class << self 
        attr_reader :config

        def configure(&blk)
            @config ||= {}
            blk.call(@config) if blk
        end
    end
end

Hoard.configure do |config|
    config.game_class = Hoard::Game
end