class GameActionsController < WebsocketRails::BaseController
  def initialize_session
    @active_games = []
  end

  def play_cards(obj)
    logger.info "Received game action event: #{obj.inspect if obj}"
  end

  def client_connected
    logger.info "Client connected!"
  end

  def client_disconnected
    logger.info "Client disconnected!"
  end

  def connection_closed
    logger.info "Client closed connection"
  end

end
