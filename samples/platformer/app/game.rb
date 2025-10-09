class Game < Hoard::Game
    GRID = 64
    SCALE = Hoard::Scaler.best_fit_f(400, 400)

    def user
      @user ||= User.new("local")
    end

    def map_path 
      "samples/platformer/data/map.ldtk"
    end

    ## work arounds for the game being nested in samples/
    def auto_load_map
      if $gtk.stat_file(map_path)
        GTK.reload_if_needed map_path
        @root = Hoard::Ldtk::Root.import($gtk.parse_json_file(map_path))
        Array.each(@root.levels) do |level|
          Array.each(level.layer_instances.reverse) do |layer|
            layer.tileset_rel_path = layer.tileset_rel_path&.gsub("../", "samples/platformer/")
          end
        end
      end
    end

    def spawn_entity_from_ldtk(entity_class, ldtk_entity)
        ldtk_entity.definition&.tileset&.rel_path&.gsub!("../", "samples/platformer/")
        super(entity_class, ldtk_entity)
    end
end