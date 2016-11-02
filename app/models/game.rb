class Game < ActiveRecord::Base
  has_one :deck
  has_many :players

  after_create :new_deck

  FieldSize = 12
  MaxPlayers = 4
  ActivityLogSize = 4
  SetboardColWidth = 84

  MaxSecondsToFindSet = 300

  # each_cmb3 (Class method)
  # performs a ( len 3 ) statistical combination, where len is the length of the
  # in-play deck.  The combination is returned as an array-of-arrays, where the inner
  # arrays are composed of 3 SORTED integers and the outer array has
  # (len)! / ((len-3)! * 3!) elements -- which gets big very quickly for large "len" values.
  def self.each_cmb3( cmb_len )
    retval = []
    # outermost loop: i = iterate from 0 to (len-1), add i to end of all arrays
    # middle loop: j = iterate from (i+1) to (len-1), add j to middle of arrays
    # inner loop: create array with numbers (j+1) to (len-1), which may be empty.
    0.upto(cmb_len - 1) do |i|
      (i+1).upto(cmb_len - 1) do |j|
        k_arr = ((j+1)..(cmb_len - 1)).to_a
        retval += k_arr.map {|k| [i,j,k] }
      end
    end
    retval
  end

  # simple game name, in title form
  def title
    "\##{id}: \"#{name}\""
  end

  # game name, in quick-listing form
  def listing
    "[\##{id}] \"#{name}\""
  end

  # create new deck with full set of cards, and shuffle cards
  # if auto-shuffle parameter is set
  def new_deck
    if deck
      save
    else
      self.deck = Deck.new
      save && deck.shuffle
    end
  end

  # start playing the game
  def start
    return false if started?
    self.started_at = Time.now
    self.last_played_at = Time.now
    self.save
  end

  # get current gamefield
  def field
    deck.gamefield
  end

  FieldRows = {:top => 0, :middle => 1, :bottom => 2 }

  # returns all cards in given row, if Set board is rendered using three
  # horizontal rows (top, middle, bottom)
  def field_row( row )
    return [] unless FieldRows.keys.include? row
    cards_in_row = []
    field.each_with_index {|card,i| cards_in_row << card if i % 3 == FieldRows[row] }
    cards_in_row
  end

  # returns list of card, ordered by rows top-to-bottom instead of columns left-to-right
  def cards_by_node_order
    cards = []
    Game::FieldRows.sort {|a,b| a[1] <=> b[1] }.each do |kv_arr|
      cards += field_row(kv_arr[0])
    end
    cards
  end

  # return game status in human-readable form
  def status
    return 'active' if active?
    return 'finished' if finished?
    return 'waiting'
  end

  # return Score corresponding to player passed in
  def score( plyr )
    plyr.score
  end

  # has game been started?  Games musst have at least one player and a start date to be considered started.
  def waiting_to_start?
    started_at.nil?
  end

  # has game been started?
  def started?
    !(waiting_to_start?)
  end

  # has game been completed and archived?
  def paused?
    !(paused_at.nil?)
  end

  # is game currently running?
  def active?
    started? && !paused? && !finished?
  end

  # has game been completed and archived?
  def finished?
    !(finished_at.nil?)
  end

  # is this a multi-player game?
  def multiplayer?
    players.length > 1
  end

   # can players be added to this game?
  def can_add_new_player?
    waiting_to_start? && (players.length < MaxPlayers)
  end

  # list of players that can be added
  def player_add_list
    Player.all.delete_if {|player| players.include? player }
  end

  # adds player to new game -- returns player added if successful
  def add_new_player( profile )
    return false unless can_add_new_player?
    pl = Player.new
    pl.profile = profile
    self.players << pl
  end

  # remove player from new game -- returns player if removed
  def remove_player( profile )
    pl = Player.find_by_profile_id_and_game_id( profile.id, self.id )
    pl.destroy if pl
  end

  # get names of players
  def player_names
    players.map {|player| player.name }.join(' vs. ')
  end

  # returns the most recently found sets, regardless of player.
  # If :all is passed as a parameter, return all sets.
  def sets( num_most_recent = Game::ActivityLogSize )
    return [] unless (num_most_recent.is_a?(Integer) || num_most_recent == :all)
    all_sets = players.inject([]) {|s_arr, player| s_arr += player.threecardsets }
    return (num_most_recent == :all) ? all_sets.sort : all_sets.sort.slice(0,num_most_recent)
  end

  # return sum of all times to find individual sets
  def total_time
    sets(:all).inject(0) {|sum, set| sum += set.seconds_to_find }
  end

  def average_time
    (total_time / selection_count.to_f).round_with_precision 3
  end

  # fills gamefield so that it contains at least 1 set, then return array of sets.
  # The timer gets refreshed when calling this function, if any cards changed.
  # Returns an empty array if no sets are found and the deck is empty (i.e. game finished)
  def fill_gamefield_with_sets
    num_empty_cards = FieldSize - field.length
    dealt = ( deck.deal num_empty_cards if num_empty_cards > 0 )
    sets_found = find_sets
    until (sets_found.length > 0)  # assigning to temp variable "tmp_sets"
      if deck.all_dealt?
        self.finished_at = Time.now
        reset_timer
        return []
      end
      dealt = deck.deal 3
      sets_found = find_sets
    end
    reset_timer unless dealt.blank?
    sets_found
  end

  # returns an array-of-arrays where the inner array are matching sets of three Card objects,
  # or an empty array if no sets are found.
  def find_sets
    found_sets = []
    field_l = field
    Game.each_cmb3(field_l.length).each do |arr3|
      cards = arr3.map {|i| field_l[i] }
      found_sets << cards if is_set?(*cards)
    end
    found_sets
  end

  # returns field position (as zero-position index) of each card within every three-card Set in the gamefield
  def find_set_card_positions
    card_positions = {}
    field.each_with_index {|card, indx| card_positions[card.id] = indx }
    find_sets.map do |threecardset|
      threecardset.map {|card| card_positions[card.id] }
    end
  end

  # the set-finding algorithm: given three card positions (within face-up array),
  # get the cardfaces and then iterate through each attribute (color, shading,
  # shape, number) and removes all instances where only a match of 2 exists --
  # because a match of 2 means "not all the same, and not all different."
  def is_set?( card1, card2, card3 )
    cardfaces = [card1.cardface, card2.cardface, card3.cardface]
    Cardface::ATTR.each do |attr|
      return false if num_different_attr( attr, cardfaces ) == 2
    end
    true
  end

  # evaluates player submission, and if set is valid:
  # set all three cards as claimed by player passed in, then
  # return the three-card set.
  def make_set_selection( plyr, card1, card2, card3 )
    return false unless is_set?(card1, card2, card3)
    seconds_to_find = (Time.now - self.last_played_at)
    seconds_to_find = MaxSecondsToFindSet if (seconds_to_find > MaxSecondsToFindSet)
    # increment score
    plyr.score += 1
    plyr.save
    # create new set
    newset = Threecardset.new :cards => [card1, card2, card3], :player => plyr,
	                      :seconds_to_find => seconds_to_find
    newset if newset.save!
  end

  # given an array of cardfaces and an attribute, finds out how many distinct
  # attribute types exist in the array for the attribute type passed in.
  def num_different_attr( attr, cardface_arr )
    res = cardface_arr.map {|card| card.send(attr) }
    res.uniq.length
  end

private

  # pause game
  def pause
    self.paused_at = Time.now
    self.resumed_at = nil
    save
  end

  # resume game
  def resume_play
    self.paused_at = nil
    self.resumed_at = Time.now
    save
  end

  # mark game as finished
  def finish
    self.finished_at = Time.now
    save
  end

end
