class Player < ActiveRecord::Base
  belongs_to :game
  belongs_to :profile
  has_many :threecardsets

  # gets full name, as string
  def name
    profile.user.name
  end

  # # skill level
  # def readable_skill_level(opts = {})
  #   is_article = (opts && opts[:article]) || false
  #   article = ((("AEIOU".include? skill_level.name[0]) ? 'an ' : 'a ') if is_article).to_s
  #   return article + skill_level.name + ' Setsolver' if skill_level
  #   article + 'a new player'
  # end

  # returns player name as an identifier
  def name_as_identifier
    id.to_s + '_' + name.downcase.gsub(/\s/,'_')
  end

  # return player number, starting with player #1
  def number( gm )
    num = nil
    gm.players.each_with_index{|pl, i| num = i if (pl == self) }
    (num + 1) if num.is_a? Integer
  end


end
