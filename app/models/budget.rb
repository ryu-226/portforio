class Budget < ApplicationRecord
  belongs_to :user

  validates :monthly_budget, presence: true, numericality: { greater_than: 0 }
  validates :draw_days, presence: true, numericality: { greater_than: 0 }
  validates :min_amount, presence: true, numericality: { greater_than: 0 }
  validates :max_amount, presence: true

  validate :max_greater_than_min
  validate :monthly_budget_greater_than_min_and_max

  private

  def max_greater_than_min
    if max_amount.present? && min_amount.present? && max_amount <= min_amount
      errors.add(:max_amount, "は最低金額より大きくしてください")
    end
  end

  def monthly_budget_greater_than_min_and_max
    if monthly_budget.present? && min_amount.present? && monthly_budget < min_amount
      errors.add(:monthly_budget, "は1日の最低金額以上に設定してください")
    elsif monthly_budget.present? && max_amount.present? && monthly_budget <= max_amount
      errors.add(:monthly_budget, "は1日の最高金額以上に設定してください")
    end
  end
end
