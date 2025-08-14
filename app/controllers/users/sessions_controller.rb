class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    post_login_path_for(resource)
  end
end
