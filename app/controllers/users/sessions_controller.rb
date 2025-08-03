class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    year_month = Date.current.strftime('%Y-%m')
    if resource.budget_for(year_month).nil?
      new_budget_path(from_signup: '1')
    else
      main_path
    end
  end
end
