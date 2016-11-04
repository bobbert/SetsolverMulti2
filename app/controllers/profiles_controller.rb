class ProfilesController < ApplicationController

  # user dashboard / home page
  def home
    current_user
    @games = @current_profile.games
    respond_to do |format|
      format.html # home.html.erb
      format.json  { render :json => @current_profile }
    end
  end

  # page for viewing games
  def archives
    current_user
    respond_to do |format|
      format.html # archives.html.erb
      format.json  { render :json => @games }
    end
  end

  # user dashboard / home page
  def howtoplay
    respond_to do |format|
      format.html # home.html.erb
      format.json  { head :ok }
    end
  end


end
