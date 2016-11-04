class GamesController < ApplicationController
  include ApplicationHelper

    #------ Game resource methods ----#

    # GET /games
    # GET /games.json
    def index
      # listing all games within selected player
      current_user
      @games = @current_profile.games
      respond_to do |format|
        format.html # index.html.erb
        format.json  { render :json => @games }
      end
    end

    # GET /games/1
    # GET /games/1.json
    def show
      get_game
      respond_to do |format|
        format.html { redirect_to(archive_url) if @game.finished? }
        format.json  { render :json => @game }
      end
    end

    # GET /games/new
    # GET /games/new.json
    def new
      current_user
      @game = Game.new
      respond_to do |format|
        format.html # new.html.erb
        format.json  { render :json => @game }
      end
    end

    # GET /games/1/edit
    def edit
      true
    end

    # POST /games
    # POST /games.json
    def create
      current_user
      # create game and save
      @game = Game.new(game_params)
      respond_to do |format|
        # creating new game, and new association between selected player and game
        if @game.add_new_player(@current_profile) && @game.save
          flash[:notice] = 'Game was successfully created.'
          format.html { redirect_to(games_url) }
          format.json  { render :json => @game, :status => :created, :location => @game }
        else
          format.html { render :action => "new" }
          format.json  { render :json => @game.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /games/1
    # PUT /games/1.json
    def update
      get_game
      respond_to do |format|
        if @game.update_attributes(game_params)
          flash[:notice] = 'Game was successfully updated.'
          format.html { redirect_to(@game) }
          format.json  { head :ok }
        else
          format.html { render :action => "edit" }
          format.json  { render :json => @game.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /games/1
    # DELETE /games/1.json
    def destroy
      # delete Score first, then Game
      get_game
      @game.players.each {|p| p.destroy }
      @game.destroy

      respond_to do |format|
        format.html { redirect_to(games_url) }
        format.json  { head :ok }
      end
    end

  #------ my controller methods ----#

  # GET /games/1/play
  # GET /games/1/play.json
  # plays submitted Set cards if submit button was clicked, then refreshes board
  def play
    get_game
    @game.start if @game.waiting_to_start?
    if update_field
      render :action => 'play'
    else
      redirect_to :action => 'archive'
    end
  end

  # GET /games/1/archive
  # GET /games/1/archive.json
  # plays submitted Set cards if submit button was clicked, then refreshes board
  def archive
    get_game
    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @game }
    end
  end

    # PUT /games/1/play_cards.json
    # the heart of the Setsolver game logic lies here.
    # This method handles new games, and all types of card submissions
    # (valid set, invalid set, wrong # of cards selected, etc. )
    def play_cards
      get_game
      selection = params[:cards].split(",")
      selection_cards = selection.map {|str_indx| @game.flat_field[str_indx.to_i] }
      if (selection_cards.compact.length != 3)
        render :json => {
          :state => :bad_move,
          :error => 'You did not select three cards.'
        }
        return true
      end
      @found_set = @game.make_set_selection(@current_player, *selection_cards)
      unless @found_set
        render :json => {
          :state => :bad_move,
          :error => 'The three cards you selected are not a set.'
        }
        return true
      end
      if update_field
        return get_field
      end
      render :json => {:state => :finished}
    end

    # GET /games/1/field.json
    # Ajax refresh routine for auto-selection
    def get_field
      get_game if @game.blank?
      update_field if @set_count < 1
      response = {
        :field => @game.flat_field.map {|card| {:name => card.name, :image => card.img_path} },
        :cards_remaining => @game.cards_remaining,
        :set_count => @set_count,
        :scores => @game.players.map {|plyr| {:score => plyr.score, :id => plyr.id} }
      }
      unless @found_set.blank?
        response[:set] = {
          :created_at => formatted_date(@found_set.created_at),
          :cards => @found_set.cards.map {|card| {:name => card.name, :image => card.small_img_path} }
        }
        response[:set_found_by] = @found_set.player.name
        response[:state] = :good_move
      end
      render :json => response
      return true
    end

    def howtoplay
      respond_to do |format|
        format.html {  }
        format.json  { head :ok }
      end
    end

    def archives
      respond_to do |format|
        format.html {  }
        format.json  { head :ok }
      end
    end

  protected

    def not_found
      flash[:error] = "Game ##{params[:id]} does not exist."
      redirect_to games_url
    end

    def user_not_playing_game
      flash[:error] = "You cannot play game ##{params[:id]}."
      redirect_to games_url
    end

    def invalid_game_state
      flash[:error] = "Game ##{params[:id]} must be either Waiting, Active, or Finished. " +
  	            "Contact the Setsolver developer for further assistance."
      redirect_to games_url
    end

  private

    # update set field.  Return false if game can no longer be played.
    def update_field
      @set_count = @game.fill_gamefield_with_sets.count
      !(@game.finished?)
    end

    # get Game object if a game ID was passed in.
    # This routine throws a UserNotPlayingGame error if the game ID passed in
    # is not being played by the current user.
    def get_game
      current_user if @current_user.blank?  # get user and profile
      @set_count = 0
      @found_set = nil
      if (params[:id])
        @game = Game.find(params[:id])
        @current_player = Player.find_by_profile_id_and_game_id(@current_profile.id, @game.id)
      end
      true
    end

    # get card numbers from params hash that takes the following form:
    # key = :card<number>, value = "SELECTED"
    # The array of card numbers is always in numerical order.
    def get_card_numbers
      cardparams = game_params.clone.delete_if do |k,v|
        (v.to_s != 'SELECTED') || (k.to_s !~ /^card[0-9]+$/)
      end
      nums = cardparams.map {|cardparam| cardparam.to_s.sub(/^card/,'').to_i }.sort
    end

    def game_params
      params.require(:game).permit(:name)
    end
end
