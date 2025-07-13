class Budget < ApplicationRecord
  belongs_to :user
  validates :monthly_budget, presence: true, numericality: { greater_than: 0 }
  validates :draw_days, presence: true, numericality: { greater_than: 0 }
  validates :min_amount, presence: true, numericality: { greater_than: 0 }
  validates :max_amount, presence: true
  validate :max_greater_than_min

  private

  def max_greater_than_min
    if max_amount.present? && min_amount.present? && max_amount <= min_amount
      errors.add(:max_amount, "は最小金額より大きくしてください")
    end
  end
end
