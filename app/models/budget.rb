class Budget < ApplicationRecord
  belongs_to :user

  validates :monthly_budget, presence: true, numericality: { greater_than: 0 }
  validates :draw_days, presence: true, numericality: { greater_than: 0 }
  validates :min_amount, presence: true, numericality: { greater_than: 0 }
  validates :max_amount, presence: true, numericality: { only_integer: true }
  validates :year_month, presence: true, uniqueness: { scope: :user_id }

  validate :max_greater_than_min
  validate :monthly_budget_greater_than_min_and_max
  validate :draw_days_cannot_exceed_days_in_month
  validate :draw_days_changeable
  validate :draw_days_within_used_plus_remaining_days
  validate :remaining_budget_within_limits

  before_validation :set_year_month, on: [:create]

  private

  def set_year_month
    self.year_month ||= Date.current.strftime('%Y-%m')
  end

  def max_greater_than_min
    if max_amount.present? && min_amount.present? && max_amount <= min_amount
      errors.add(:max_amount, "は最低予算より大きく設定してください")
    end
  end

  def monthly_budget_greater_than_min_and_max
    if monthly_budget.present? && min_amount.present? && monthly_budget < min_amount
      errors.add(:monthly_budget, "は1日の最低予算以上にしてください")
    elsif monthly_budget.present? && max_amount.present? && monthly_budget <= max_amount
      errors.add(:monthly_budget, "は1日の最高予算より多く設定してください")
    end
  end

  def draw_days_cannot_exceed_days_in_month
    return if draw_days.blank?
    total_days = Date.current.end_of_month.day
    if draw_days.to_i > total_days
      errors.add(:draw_days, "は今月の日数（#{total_days}日）以内で設定してください")
    end
  end

  def draw_days_changeable
    return unless persisted? && user.present?
    used = draws_this_month_count
    if draw_days.present? && draw_days.to_i < used
      errors.add(:draw_days, "は、すでにガチャ済みの日数（#{used}回）より少なくはできません")
    end
  end

  def draw_days_within_used_plus_remaining_days
    return unless draw_days.present? && user.present?

    used = draws_this_month_count
    today = Date.current
    
    remaining_calendar_days = (today..today.end_of_month).count
    drawn_today = user.draws.exists?(date: today)
    available_days = remaining_calendar_days - (drawn_today ? 1 : 0)
    max_possible = used + available_days

    if draw_days.to_i > max_possible
      suffix = drawn_today ? "（今日分はガチャ済）" : ""
      errors.add(:draw_days, "は今月すでにガチャ済みの#{used}回と、今日から月末まで#{suffix}の残り#{available_days}日を合わせた#{max_possible}日以内で設定してください")
    end
  end

  def remaining_budget_within_limits
    return unless user.present? && draw_days.present? && monthly_budget.present? && min_amount.present? && max_amount.present?

    used_count = draws_this_month_count
    used_sum = draws_this_month_sum

    remain_count = draw_days.to_i - used_count
    remain_budget = monthly_budget.to_i - used_sum

    return if remain_count <= 0

    if remain_budget < remain_count * min_amount
      errors.add(:monthly_budget, "やガチャする日数の組み合わせに問題があります（残りガチャ日数×最低予算が残り予算を超えています）。条件を見直してください）")
    end

    if remain_budget > remain_count * max_amount
      errors.add(:monthly_budget, "やガチャする日数の組み合わせに問題があります（残りガチャ日数×最高予算が残り予算より少ないです）。条件を見直してください）")
    end
  end

  # 共通メソッド
  def draws_this_month_count
    user.draws.where(date: Date.current.all_month).count
  end

  def draws_this_month_sum
    user.draws.where(date: Date.current.all_month).sum(:amount)
  end
end