class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_one :budget
  has_many :draws, dependent: :destroy

  validates :nickname, presence: true

  validate :password_complexity

  private

  def password_complexity
    return if password.blank?

    unless password =~ /[a-zA-Z]/ && password =~ /\d/
      errors.add :password, "は英字と数字の両方を含めてください"
    end
  end
end
