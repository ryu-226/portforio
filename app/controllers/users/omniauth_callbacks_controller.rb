class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable

  def google_oauth2
    auth  = request.env["omniauth.auth"]
    email = auth&.info&.email
    created_now = email.present? && !User.exists?(email: email)

    @user = User.from_omniauth(auth)

    if @user&.persisted?
      sign_in(@user)
      remember_me(@user)
      redirect_to post_login_path_for(@user, created_now: created_now)
    else
      redirect_to new_user_session_path, alert: t('omniauth.login_failure')
    end
  end

  def failure
    redirect_to new_user_session_path, alert: t('omniauth.canceled_or_failed')
  end
end
