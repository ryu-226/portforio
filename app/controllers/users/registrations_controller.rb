class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # 新規登録後にリダイレクトするパスとメッセージを指定
  def after_sign_up_path_for(resource)
    new_budget_path.tap do |path|
      flash[:notice] = "会員登録が完了しました"
    end
  end
end
