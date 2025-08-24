class DrawStats
  Result = Struct.new(
    :drawn_count, :drawn_sum,
    :remaining_days, :remaining_budget,
    :month_range,
    keyword_init: true
  )

  # date はその月の任意の日（既定：今日）
  def self.for(user:, budget:, date: Time.zone.today)
    month = date.all_month
    rel = user.draws.where(date: month)

    drawn_count = rel.count
    drawn_sum = rel.sum(:amount).to_i

    remaining_days = budget ? budget.draw_days.to_i - drawn_count : nil
    remaining_budget = budget ? budget.monthly_budget.to_i - drawn_sum : nil

    Result.new(
      drawn_count: drawn_count,
      drawn_sum: drawn_sum,
      remaining_days: remaining_days,
      remaining_budget: remaining_budget,
      month_range: month
    )
  end
end
