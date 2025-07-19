class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  private

  def require_login
    unless logged_in?
       redirect_to login_path, alert: "ログインしてください"
    end
  end
end
