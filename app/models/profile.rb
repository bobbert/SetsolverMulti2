class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :players

  # increment game play count by 1; also increment win or loss count
  # based on win_loss_result value (:win, :loss, or nil)
  def add_completed_game(win_loss_result = nil)
    self.games_played = games_played.to_i + 1
    if win_loss_result == :win
      self.wins = wins.to_i + 1
    elsif win_loss_result == :loss
      self.losses = losses.to_i + 1
    end
    save
  end

  def name
    user.name if user
  end

  def games
    players.map {|pl| pl.game }
  end

  def games_waiting_to_start
    players.map {|pl| pl.game if pl.game.waiting_to_start? }.compact
  end

  # does at least one active game exist?
  def has_games_waiting_to_start?
    games_waiting_to_start.length > 0
  end

  # does at least one active game exist?
  def has_active_games?
    active_games.length > 0
  end

  # get all active games
  def active_games
    players.map {|pl| pl.game if pl.game.active? }.compact
  end

  # does at least one archived game exist?
  def has_archived_games?
    archived_games.length > 0
  end

  # get all games completed by this player
  def archived_games
    players.map {|pl| pl.game if pl.game.finished? }.compact
  end

  # does player have both active and waiting games?
  def has_games_active_and_waiting_to_start?
    has_games_waiting_to_start? && has_active_games?
  end

  # returns last game completely finished
  def last_finished_game
    archived_games.sort_by {|g| g.finished_at }.last
  end

  # print player's full profile stats
  def full_profile
    "#{name}: #{archived_games.length} games finished."
  end

end
