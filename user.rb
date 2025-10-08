module Hoard
  class User < Entity
    attr_reader :username, :player_card_icon, :player
    attr_accessor :camera

    script Scripts::DocumentStoresScript.new
    script Scripts::DocumentStoreScript.new(id: "default")
    script Scripts::SaveDataScript.new

    def initialize(username, player_card_icon = nil)
      @username = username
      @player_card_icon = player_card_icon
      @player = nil
      @camera = nil

      super()
    end

    def spawn_player(player_template, position = nil, rotation = nil)
      despawn_player if @player

      @player = player_template.new(parent: self)
      if position && rotation
        @player.position = position
        @player.rotation = rotation
      end

      yield @player if block_given?

      @player
    end

    def despawn_player
      return unless @player

      @player.destroy! if @player.respond_to?(:destroy!)
      @player = nil

      yield if block_given?
    end
  end
end
