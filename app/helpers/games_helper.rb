module GamesHelper
  # renders wait text for when user submits three-card set.
  def wait_text
    str = 'Waiting for results... ' + image_tag('spinner.gif', :alt => 'spinner')
  end

  # prints three card set as miniature cards
  def render_threecard_set( tcs )
    return render_dummy_set if tcs.blank?
    cards = (tcs.is_a? Threecardset) ? tcs.cards : tcs
    cards.inject('') do |str,c|
      str += ' ' unless str.length == 0
      str += extra_small_setcard_img(c)
    end
  end

  # prints three card set as miniature cards, given cardface ID's
  def render_threecard_set_from_cardface_ids( *cf_ids )
    render_threecard_set( cf_ids.map {|id| Cardface.find(id) } )
  end

  # renders an extra-small Set card
  def extra_small_setcard_img( card )
    image_tag(card.small_img_path, :height => 45, :width => 30, :alt => card.to_s)
  end

  # renders an invisible dummy set
  def render_dummy_set
    str = ""
    3.times do |x|
      str += ' ' unless str.length == 0
      str += image_tag( 'cards/card_template.png' )
    end
    str
  end

  # create game number as link
  def game_desc_as_link( gm )
    link_to(gm.listing, game_path(gm))
  end

  # create game number as link
  def game_play_link( gm )
    if gm.waiting_to_start?
      link_to("Start playing!", play_path(gm), :class => 'mock-fb-button')
    elsif gm.active?
      link_to("Continue playing", play_path(gm), :class => 'mock-fb-button')
    elsif gm.finished?
      link_to("Game Archive", archive_path(gm), :class => 'mock-fb-button')
    else
      raise Exceptions::InvalidGameState
    end
  end

  # returns image HTML for a single card
  def card_image( card )
    image_tag(card.img_path, :height => 90, :width => 60, :alt => card.to_s)
  end

  def render_set_found_text( set )
    "<h5>#{formatted_date(set.created_at) if set}</h5> " +
    "<span class=\"setlisting-name\">#{set.player.name if set}</span> found a set: " +
    "<p class=\"setlisting\">#{render_threecard_set(set)}</p> "
  end

end
