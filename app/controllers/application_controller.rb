class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_draw_status
    year_month = Date.current.strftime('%Y-%m')
    budget = current_user.budget_for(year_month)

    today = Date.current
    month_range = today.beginning_of_month..today.end_of_month
    draws_this_month = current_user.draws.where(date: month_range)

    @drawn_count = draws_this_month.count
    @drawn_sum = draws_this_month.sum(:amount)

    if budget.present?
      @remaining_days = budget&.draw_days.to_i - @drawn_count
      @remaining_budget = budget&.monthly_budget.to_i - @drawn_sum
    else
      @remaining_days = nil
      @remaining_budget = nil
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end
end
