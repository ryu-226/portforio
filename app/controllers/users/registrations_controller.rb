class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_registration_path
  end

  # サニタイザに「必ず」password系を含める
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: [:nickname, :email, :password, :password_confirmation, :current_password])
  end

  # Devise の更新ロジックを条件付きで変更
  def update_resource(resource, params)
    if resource.provider.present? && resource.encrypted_password.blank?
      # 初回（現在PWなし）だけ current_password を不要にする
      attrs = params.except(:current_password, "current_password")

      if attrs[:password].present?
        # 初回のパスワード設定は「update」を使う
        resource.update(attrs)
      else
        # パスワード未入力＝メール等だけ変更したい場合は今まで通り
        resource.update_without_password(attrs)  # password を触らない更新
      end
    else
      super
    end
  end

  # 更新後の遷移
  def after_update_path_for(resource)
    mypage_path
  end
end
