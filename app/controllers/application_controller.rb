class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private

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

  helper_method :current_user

end
