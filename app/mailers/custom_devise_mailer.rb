class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  # 新規確認／再確認の両方で呼ばれるメソッドをオーバーライド
  def confirmation_instructions(record, token, opts = {})
    if record.respond_to?(:unconfirmed_email) && record.unconfirmed_email.present?
      # 新アドレス確認用
      opts[:template_name] = :email_change_confirmation_instructions
    else
      # アカウント有効化用
      opts[:template_name] = :confirmation_instructions
    end

    super
  end
end
