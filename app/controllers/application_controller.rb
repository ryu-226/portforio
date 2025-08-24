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

    today  = Date.current
    budget = current_user.budget_for(today.strftime('%Y-%m'))
    stats  = DrawStats.for(user: current_user, budget: budget, date: today)

    @drawn_count      = stats.drawn_count
    @drawn_sum        = stats.drawn_sum
    @remaining_days   = stats.remaining_days
    @remaining_budget = stats.remaining_budget
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
