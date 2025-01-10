module Hoard
  class User < Entity
    attr_reader :username, :player_card_icon, :player
    attr_accessor :camera

    def initialize(username, player_card_icon = nil)
      @username = username
      @player_card_icon = player_card_icon
      @player = nil
      @camera = nil

      super(0, 0, nil)
    end

    def spawn_player(player_template, position = nil, rotation = nil)
      despawn_player if @player

      @player = player_template.new(user: self)
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
