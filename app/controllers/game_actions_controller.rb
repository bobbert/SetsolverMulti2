class GameActionsController < WebsocketRails::BaseController
  def initialize_session
    @active_games = []
  end

  def play_cards
    logger.info "Start method."
    player = get_player_if_valid(message)
    logger.info "Got player."
    if (player.blank?)
      logger.info "Invalid message."
      send_message :game_message, {error: 'You are not a player of this game.'}
    else
      game_state = player.game.get_game_state
      logger.info "Received valid game action: channel = #{:update_game}, message = #{game_state}"
      broadcast_message(:update_game, game_state)
    end
  end

  def client_connected
    logger.info "Client connected!"
    send_message :user_info, {:user => current_user.screen_name}
  end

  def client_disconnected
    logger.info "Client disconnected!"
  end

  def connection_closed
    logger.info "Client closed connection"
  end

private

  def get_player_if_valid(message)
    logger.info "start"
    user = current_user
    logger.info "user = #{user}"
    game = Game.find(message[:game_id])
    logger.info "game = #{game}"
    player = game.players.find {|player| player.profile.user == user }
    logger.info "player = #{player}"
    return player
  end

# RWP TEMP - redundant method.  DRY this up by putting this method in a module, etc.
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
      @current_profile ||= Profile.find_by_user_id(session[:user_id])
      if @current_profile.nil?
        @current_profile = Profile.new :user_id => session[:user_id]
        @current_profile.save!
      end
    end
    @current_user
  end

end
