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

  def set_draw_status
    budget = current_user&.budget
    today = Date.current
    month_range = today.beginning_of_month..today.end_of_month
    draws_this_month = current_user.draws.where(date: month_range)
    @drawn_count = draws_this_month.count
    @drawn_sum = draws_this_month.sum(:amount)
    @remaining_days = budget&.draw_days.to_i - @drawn_count
    @remaining_budget = budget&.monthly_budget.to_i - @drawn_sum
  end
end
