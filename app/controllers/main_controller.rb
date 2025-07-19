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
    if current_user.draws.exists?(date: Date.current)
      redirect_to main_path, alert: "本日はすでにガチャを回しています"
      return
    end

    budget = current_user.budget
    unless budget
      redirect_to new_budget_path, alert: "まずは予算を設定して下さい"
      return
    end

    # 現在は単純に min_amount〜max_amount で乱数
    amount = rand(budget.min_amount..budget.max_amount)

    @draw = current_user.draws.create!(
      date: Date.current,
      amount: amount
    )

    flash[:draw_amount] = amount
    redirect_to main_path
  end
end
