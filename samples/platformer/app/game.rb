class Game < Hoard::Game 
    GRID = 64
    SCALE = Hoard::Scaler.best_fit_f(400, 400)

    def user 
      @user = User.new("local")
    end

    ## work arounds for the game being nested in samples/
    def auto_load_map
        map_path = "samples/platformer/data/map.ldtk"
        if $gtk.stat_file(map_path)
          @root = Hoard::Ldtk::Root.import($gtk.parse_json_file(map_path))
          Array.each(@root.levels[0].layer_instances.reverse) do |layer|
            layer.tileset_rel_path = layer.tileset_rel_path&.gsub("../", "samples/platformer/")
          end
          auto_start_first_level if @root
        end
    end

    def spawn_entity_from_ldtk(entity_class, ldtk_entity)
        ldtk_entity.definition&.tileset&.rel_path&.gsub!("../", "samples/platformer/")
        super(entity_class, ldtk_entity)
    end
end