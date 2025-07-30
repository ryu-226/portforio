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
  validate :remaining_budget_within_limits

  private

  def max_greater_than_min
    if max_amount.present? && min_amount.present? && max_amount <= min_amount
      errors.add(:max_amount, "は最低金額より大きく設定してください")
    end
  end

  def monthly_budget_greater_than_min_and_max
    if monthly_budget.present? && min_amount.present? && monthly_budget < min_amount
      errors.add(:monthly_budget, "は1日の最低金額以上にしてください")
    elsif monthly_budget.present? && max_amount.present? && monthly_budget <= max_amount
      errors.add(:monthly_budget, "は1日の最高金額より多く設定してください")
    end
  end

  def draw_days_cannot_exceed_days_in_month
    total_days_in_month = Date.current.end_of_month.day
    if draw_days.present? && draw_days.to_i > total_days_in_month
      errors.add(:draw_days, "は今月の日数（#{total_days_in_month}日）以内で設定してください")
    end
  end

  def draw_days_changeable
    return unless persisted?
    month_range = Date.current.beginning_of_month..Date.current.end_of_month
    used = user.draws.where(date: month_range).count
    if draw_days.present? && draw_days.to_i < used
      errors.add(:draw_days, "は、すでにガチャを回した日数（#{used}回）より少なくはできません")
    end
  end

  def remaining_budget_within_limits
    month_range = Date.current.beginning_of_month..Date.current.end_of_month
    used_count = user.draws.where(date: month_range).count
    used_sum = user.draws.where(date: month_range).sum(:amount)
    remain_count = draw_days.to_i - used_count
    remain_budget = monthly_budget.to_i - used_sum

    if remain_count > 0
      if remain_budget < remain_count * min_amount
        errors.add(:monthly_budget, "や抽選日数の組み合わせに問題があります（残り抽選日数×最低金額が残り予算を超えています）。条件を見直してください）")
      end
      if remain_budget > remain_count * max_amount
        errors.add(:monthly_budget, "や抽選日数の組み合わせに問題があります（残り抽選日数×最高金額が残り予算より少ないです）。条件を見直してください）")
      end
    end
  end
end
