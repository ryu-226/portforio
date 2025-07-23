class User < ApplicationRecord
  has_secure_password
  has_one :budget
  has_many :draws, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/, message: "は有効なメールアドレスを入力してください" }
  validates :nickname, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validate :password_must_include_alphabet_and_number, if: -> { password.present? }
  validate :email_must_be_alphanumeric, if: -> { email.present? }

  private

  def password_must_include_alphabet_and_number
    unless password =~ /[a-zA-Z]/ && password =~ /\d/
      errors.add(:password, "は英字と数字を両方含めてください")
    end
    unless password =~ /\A[a-zA-Z0-9]+\z/
      errors.add(:password, "は半角英数字のみ使用できます")
    end
  end

  def email_must_be_alphanumeric
    unless email =~ /\A[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\z/
      errors.add(:email, "は半角英数字で正しく入力してください")
    end
  end
end
