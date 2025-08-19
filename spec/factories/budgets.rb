FactoryBot.define do
  factory :budget do
    association :user
    year_month { Date.current.strftime("%Y-%m") }
    min_amount { 500 }
    max_amount { 1500 }

    transient do
      today { Date.current }
    end

    draw_days do
      days_left = (today..today.end_of_month).count
      [days_left - 1, 1].max.to_s
    end

    monthly_budget do
      d = draw_days.to_i
      (min_amount * d) + (((max_amount - min_amount) * d) / 2)
    end
  end
end
