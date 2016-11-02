module ApplicationHelper

  # handles printing number as adjective followed by noun using
  # built-in Rails functions.
  def number_noun_desc( num, noun )
    return "1 #{noun.singularize}" if num == 1
    return "#{num} #{noun.pluralize}"
  end

  # returns Yes or No based on Boolean value of object passed in
  def format_yn( expr )
    return (expr) ? 'Yes' : 'No'
  end

  def formatted_date( date )
    date.strftime("%m/%d/%Y %I:%M:%S %p") if date
  end

  def default_game_name
    "#{@current_profile.name}'s #{(@current_profile.games.length + 1).ordinalize} game"
  end

  def print_example_cards
    example_txt = '<table style="width:720px">'
    card_messages = Cardface.example_cardfaces.each_with_index do |cardface, i|
      inner_txt = ((i%3 == 0) ? '<tr><td>' : '<td>')
      inner_txt += "#{extra_small_setcard_img(cardface)}: <strong>#{cardface.to_s}</strong>"
      inner_txt += ((i%3 < 2) ? '</td>' : '</td></tr>')
      example_txt += inner_txt
    end
    example_txt + '</table>'
  end

end
