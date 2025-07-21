class MainController < ApplicationController
  before_action :require_login

  def index
    @draw = current_user.draws.find_by(date: Date.current)
    @budget = current_user.budget
    unless @budget
      redirect_to new_budget_path, alert: "まずは予算を設定してください"
      return
    end

    @low_messages = [
      "セーブデー！賢く使おう",
      "節約ランチでお得気分♪",
      "ランチの工夫が腕の見せどころ！",
      "今日はお財布にやさしく！",
      "コスパ最強ランチを狙おう！"
    ]
    @middle_messages = [
      "ランチタイムも楽しくガチャ！",
      "ランチ仲間とシェアするのもおすすめ！",
      "迷ったら定番メニュー！",
      "おいしいランチでリフレッシュ！",
      "バランスの良い食事を心がけよう！"
    ]
    @high_messages = [
      "今日は豪華ランチいけるかも！",
      "たまにはご褒美ランチも♪",
      "今日はお気に入りのお店に行くチャンス！",
      "ランチ仲間とプチ贅沢しよう！",
      "美味しいもの食べて午後も頑張ろう！"
    ]

    @draw_message = nil

    if @draw && @budget
      min = @budget.min_amount
      max = @budget.max_amount
      range = max - min
      twenty_percent = (range * 0.2).round

      low_max = min + twenty_percent
      high_min = max - twenty_percent + 1

      amount = @draw.amount

      if amount <= low_max
        @draw_message = @low_messages.sample
      elsif amount >= high_min
        @draw_message = @high_messages.sample
      else
        @draw_message = @middle_messages.sample
      end
    end
  end

  def draw
    today = Date.current
    budget = current_user.budget
    unless budget
      redirect_to new_budget_path, alert: "まずは予算を設定してください"
      return
    end

    if current_user.draws.exists?(date: today)
      redirect_to main_path, alert: "本日はすでにガチャを回しています"
      return
    end

    month_range = today.beginning_of_month..today.end_of_month
    draws_this_month = current_user.draws.where(date: month_range)
    drawn_count = draws_this_month.count
    drawn_sum = draws_this_month.sum(:amount)

    remaining_days = budget.draw_days.to_i - drawn_count
    remaining_budget = budget.monthly_budget.to_i - drawn_sum

    if remaining_days <= 0
      redirect_to main_path, alert: "今月のガチャ回数が上限に達しました"
      return
    end

    if (remaining_days * budget.min_amount.to_i) > remaining_budget ||
       (remaining_days * budget.max_amount.to_i) < remaining_budget
      redirect_to edit_budget_path, alert: "残り予算と残り抽選回数に合わない条件です。設定を見直してください。"
      return
    end

    if remaining_days == 1
      amount = remaining_budget
    else
      min = [budget.min_amount.to_i, remaining_budget - (budget.max_amount.to_i * (remaining_days - 1))].max
      max = [budget.max_amount.to_i, remaining_budget - (budget.min_amount.to_i * (remaining_days - 1))].min

      interval = ((max - min + 1) / 3.0).ceil

      low_min = min
      low_max = [min + interval - 1, max].min
      mid_min = [low_max + 1, max].min
      mid_max = [mid_min + interval - 1, max].min
      high_min = [mid_max + 1, max].min
      high_max = max

      r = rand(3)
      amount =
        case r
        when 0
          rand(low_min..low_max)
        when 1
          rand(mid_min..mid_max)
        when 2
          rand(high_min..high_max)
        end

      amount = (amount / 10) * 10
      amount = [min, [amount, max].min].max
    end

    @draw = current_user.draws.create!(
      date: today,
      amount: amount
    )

    flash[:draw_amount] = amount
    redirect_to main_path
  end
end
