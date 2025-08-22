class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :draws, dependent: :destroy
  has_many :budgets

  validates :nickname, presence: true

  validate :password_complexity

  # Google経由作成時はパスワード未入力で作成OKにする
  def password_required?
    return false if provider.present? && uid.present? && !password.present?

    super
  end

  # Google作成時はパスワードを「保存しない」
  def self.from_omniauth(auth)
    email = auth.info.email
    return nil if email.blank?

    if (user = find_by(email: email))
      if user.provider.blank? || user.uid.blank?
        user.update(provider: auth.provider, uid: auth.uid,
                    image: auth.info.image)
      end
      return user
    end

    user = new(
      email: email,
      nickname: auth.info.name.presence || email.split("@").first,
      provider: auth.provider,
      uid: auth.uid,
      image: auth.info.image
    )

    # confirmable 利用時：Googleのメールは本人性が高いので確認をスキップ
    user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    user.save ? user : nil
  end

  def budget_for(year_month)
    budgets.find_by(year_month: year_month)
  end

  private

  def password_complexity
    return if password.blank?

    errors.add :password, "は英字と数字の両方を含めてください" unless password =~ /[a-zA-Z]/ && password =~ /\d/
  end
end
