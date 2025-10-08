module Hoard
  class Game < Process
    attr_gtk

    attr :camera, :fx, :current_level, :hud, :slow_mos, :root
    attr :cur_game_speed, :scroller

    UI = { x: 0, y: 0, h: 720, w: 1280, path: :ui }

    class << self
      @grid = 16

      attr :grid
    end

    def initialize
      super

      @slow_mos = {}
      @cur_game_speed = 1

      @scroller = Layer.new(:scene)
      @camera = Camera.new

      @fx = Fx.new

      # Auto-load map if it exists
      auto_load_map
    end

    def start_level(level)
      destroy_all_children!
      @current_level = level
      @camera.center_on_target
      spawn_ldtk_entities(level)
    end

    ##
    # Start a cumulative slow-motion effect that will affect 'tmod' value in this Process
    # and all its children
    #
    # @param sec Realtime second duration of this slowmo
    # @param speed_factor Cumulative multiplier to this Process 'tmod'
    def add_slowmo(id, sec, speed_factor = 0.3)
      if slow_mos[id]
        s = slow_mos[id]
        s[:f] = speed_factor
        s[:t] = [s[:t], sec].max
      else
        slow_mos[id] = {
          id: id,
          t: sec,
          f: speed_factor,
        }
      end
    end

    def update_slow_mos
      slow_mos.each do |k, v|
        v[:t] -= utmod * 1 / 60
        if v[:t] <= 0
          slow_mos.delete v[:id]
        end
      end

      target_game_speed = 1
      slow_mos.each do |k, v|
        target_game_speed *= v[:f]
      end

      self.cur_game_speed = (target_game_speed - cur_game_speed) * (target_game_speed > cur_game_speed ? 0.2 : 0.6)

      if (cur_game_speed - target_game_speed).abs <= 0.001
        cur_game_speed = target_game_speed
      end
    end

    def stop_frame
      # ucd.setS("stopFrame", 4/60)
    end

    def post_update
      update_slow_mos

      self.base_time_mul = (0.2 + 0.8 * cur_game_speed) * (ucd.has("stopFrame") ? 0.1 : 1)

      render
    end

    def self.s
      @@instance ||= new
    end

    def tick
      Process.update_all(utmod)
      Scheduler.tick
    end

    def pre_update
      args.outputs[:ui].transient!
      args.outputs[:scene].transient!
    end

    def render
      if @current_level
        args.outputs[:scene].sprites.push @current_level
      end

      args.outputs.sprites << @scroller
      args.outputs.sprites << UI
    end

    def shutdown
      Process.shutdown
    end

    def broadcast_to_scripts(method_name, *args, &block)
      Process.broadcast_to_scripts(method_name, *args, &block)
    end

    ##
    # Convention-based player detection
    # Override this method in subclasses to provide custom player instance
    def player
      @player ||= find_player_entity
    end

    ##
    # Auto-load map.ldtk from data/ directory if it exists
    def auto_load_map
      map_path = "data/map.ldtk"
      if $gtk.stat_file(map_path)
        @root = Hoard::Ldtk::Root.import($gtk.parse_json_file(map_path))
        auto_start_first_level if @root
      end
    end

    ##
    # Start the first level in the loaded map
    def auto_start_first_level
      first_level = @root&.levels&.first
      start_level(first_level) if first_level
    end

    ##
    # Spawn all entities from LDTK level's Entities layer
    def spawn_ldtk_entities(level)
      return unless level&.layer("Entities")

      level.layer("Entities").entity_instances.each do |ldtk_entity|
        entity_class = Hoard::Entity.resolve(ldtk_entity.identifier)
        next unless entity_class

        # Special case: position player if it exists
        if ldtk_entity.identifier == "Player" && player
          spawn_player_from_ldtk(player, ldtk_entity)
        else
          spawn_entity_from_ldtk(entity_class, ldtk_entity)
        end
      end
    end

    ##
    # Spawn the player entity from LDTK entity instance
    def spawn_player_from_ldtk(player, ldtk_entity)
      player.set_pos_case(ldtk_entity.grid[0], ldtk_entity.grid[1])
      player.send_to_scripts(:ldtk_entity=, ldtk_entity)
      apply_ldtk_fields(player, ldtk_entity)
    end

    ##
    # Spawn a generic entity from LDTK entity instance
    def spawn_entity_from_ldtk(entity_class, ldtk_entity)
      entity = entity_class.new(parent: self, cx: ldtk_entity.grid[0], cy: ldtk_entity.grid[1])
      entity.send_to_scripts(:ldtk_entity=, ldtk_entity)
      apply_ldtk_fields(entity, ldtk_entity)
      entity.args = args
      entity
    end

    ##
    # Apply LDTK field instances to entity scripts
    def apply_ldtk_fields(entity, ldtk_entity)
      ldtk_entity.field_instances.each do |field|
        entity.send_to_scripts("#{field.identifier}=", field.value)
      end
    end

    private

    ##
    # Find player entity by convention (looks for Entities::Player or any class named Player)
    def find_player_entity
      player_class = Hoard::Entity.resolve("Player")
      return nil unless player_class

      # Check if player already exists as a child
      existing = children.find { |c| c.is_a?(player_class) }
      return existing if existing

      # Create new player instance
      player_class.new(parent: self)
    end

    def reset; end
    def boot; end
  end
end
