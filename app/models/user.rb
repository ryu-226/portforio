class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable

  has_many :draws, dependent: :destroy
  has_many :budgets

  validates :nickname, presence: true

  validate :password_complexity

  def budget_for(year_month)
    budgets.find_by(year_month: year_month)
  end

  private

  def password_complexity
    return if password.blank?

    unless password =~ /[a-zA-Z]/ && password =~ /\d/
      errors.add :password, "は英字と数字の両方を含めてください"
    end
  end
end
