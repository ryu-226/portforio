class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth  = request.env["omniauth.auth"]
    email = auth&.info&.email
    created_now = email.present? && !User.exists?(email: email)

    @user = User.from_omniauth(auth)

    if @user&.persisted?
      sign_in(@user)
      redirect_to post_login_path_for(@user, created_now: created_now)
    else
      redirect_to new_user_session_path, alert: "Googleログインに失敗しました"
    end
  end

  def failure
    redirect_to new_user_session_path, alert: "Googleログインがキャンセル/失敗しました"
  end
end