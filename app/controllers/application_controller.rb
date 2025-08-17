class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_draw_status

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname])
  end

  private

  def set_draw_status
    return unless user_signed_in?
    
    ym     = Date.current.strftime('%Y-%m')
    budget = current_user.budget_for(ym)

    today          = Date.current
    month_range    = today.beginning_of_month..today.end_of_month
    draws_this_mon = current_user.draws.where(date: month_range)

    @drawn_count   = draws_this_mon.count
    @drawn_sum     = draws_this_mon.sum(:amount)

    if budget.present?
      @remaining_days   = budget.draw_days.to_i     - @drawn_count
      @remaining_budget = budget.monthly_budget.to_i - @drawn_sum
    else
      @remaining_days   = nil
      @remaining_budget = nil
    end
  end

  def post_login_path_for(user, created_now: false)
    if (loc = stored_location_for(user)).present?
      return loc
    end

    ym = Date.current.strftime("%Y-%m")
    needs_budget_setup = user.budget_for(ym).blank?
    return new_budget_path(from_signup: "1") if created_now || needs_budget_setup

    main_path
  end
end
