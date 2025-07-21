class Budget < ApplicationRecord
  belongs_to :user

  validates :monthly_budget, presence: true, numericality: { greater_than: 0 }
  validates :draw_days, presence: true, numericality: { greater_than: 0 }
  validates :min_amount, presence: true, numericality: { greater_than: 0 }
  validates :max_amount, presence: true, numericality: { only_integer: true }

  validate :max_greater_than_min
  validate :monthly_budget_greater_than_min_and_max
  validate :draw_days_cannot_exceed_days_in_month
  validate :draw_days_changeable
  validate :remaining_budget_within_limits, on: :update

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

  def draw_days_cannot_exceed_days_in_month
    max_days = Date.current.end_of_month.day
    if draw_days.present? && draw_days > max_days
      errors.add(:draw_days, "は今月の日数（#{max_days}日）以下にしてください")
    end
  end

  def draw_days_changeable
    return unless persisted?
    month_range = Date.current.beginning_of_month..Date.current.end_of_month
    used = user.draws.where(date: month_range).count
    if draw_days.present? && draw_days < used
      errors.add(:draw_days, "は既に抽選した回数（#{used}回）より多く設定してください")
    end
  end

  def remaining_budget_within_limits
    month_range = Date.current.beginning_of_month..Date.current.end_of_month
    used_count = user.draws.where(date: month_range).count
    used_sum = user.draws.where(date: month_range).sum(:amount)
    remain_count = draw_days - used_count
    remain_budget = monthly_budget - used_sum
    if remain_count < 0
      errors.add(:draw_days, "は既にガチャを回した日数（#{used_count}回）以上にしてください")
    end
    if remain_count > 0
      if remain_budget < remain_count * min_amount
        errors.add(:monthly_budget, "と抽選回数・最低金額の組み合わせが不正です（残り日数×最低金額が残り予算を超えています）")
      end
      if remain_budget > remain_count * max_amount
        errors.add(:monthly_budget, "と抽選回数・最高金額の組み合わせが不正です（残り日数×最高金額が残り予算より少ないです）")
      end
    end
  end
end
