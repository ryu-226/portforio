class MainController < ApplicationController
  before_action :authenticate_user!

  def index
    @budget = current_user.budget_for(Date.current.strftime('%Y-%m'))
    @draw = current_user.draws.find_by(date: Date.current)

    if @budget.blank?
      @remaining_days = nil
      @remaining_budget = nil
      @draw_message = nil
      return
    end

    month_range = Date.current.all_month
    drawn_count = current_user.draws.where(date: month_range).count
    drawn_sum = current_user.draws.where(date: month_range).sum(:amount)
    @remaining_days = @budget.draw_days.to_i - drawn_count
    @remaining_budget = @budget.monthly_budget.to_i - drawn_sum

    # メッセージ設定
    @low_messages = [
      "セーブデー！賢く使おう",
      "節約ランチでお得気分♪",
      "ランチの工夫が腕の見せどころ！",
      "今日はお財布にやさしく！",
      "コスパ最強ランチを狙おう！"
    ]
    @middle_messages = [
      "ランチタイムでひと休み♪",
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

    return unless @draw

    picker = DrawPicker.new(
      min: @budget.min_amount,
      max: @budget.max_amount,
      remaining_days: @remaining_days,
      remaining_budget: @remaining_budget
    )

    @draw_message =
      case picker.classify(@draw.amount)
      when :low  then @low_messages.sample
      when :high then @high_messages.sample
      else            @middle_messages.sample
      end
  end

  def draw
    today = Time.zone.today
    budget = current_user.budget_for(today.strftime('%Y-%m'))

    unless budget
      redirect_to new_budget_path, alert: I18n.t('draws.need_budget', default: 'まずは予算を設定してください')
      return
    end

    if current_user.draws.exists?(date: today)
      redirect_to main_path, alert: I18n.t('draws.already_drawn_today', default: '本日はすでにガチャを回しています')
      return
    end

    month_range = today.all_month
    drawn_count = current_user.draws.where(date: month_range).count
    drawn_sum = current_user.draws.where(date: month_range).sum(:amount)
    remaining_days = budget.draw_days.to_i - drawn_count
    remaining_budget = budget.monthly_budget.to_i - drawn_sum

    if remaining_days <= 0
      redirect_to main_path, alert: I18n.t('draws.days_limit', default: '今月のガチャできる日数が上限に達しました。設定を見直してください。')
      return
    end

    if (remaining_days * budget.min_amount.to_i) > remaining_budget ||
       (remaining_days * budget.max_amount.to_i) < remaining_budget
      redirect_to edit_budget_path,
                  alert: I18n.t('draws.infeasible_combo', default: '残り予算と残りガチャ日数に合わない条件です。設定を見直してください。')
      return
    end

    amount = DrawPicker.new(
      min: budget.min_amount,
      max: budget.max_amount,
      remaining_days: remaining_days,
      remaining_budget: remaining_budget
    ).pick

    # 競合対策
    already_drawn = false
    current_user.with_lock do
      if current_user.draws.exists?(date: today)
        already_drawn = true
      else
        @draw = current_user.draws.create!(date: today, amount: amount)
      end
    end
    if already_drawn
      redirect_to main_path, alert: I18n.t('draws.already_drawn_today', default: '本日はすでにガチャを回しています')
      return
    end

    flash[:draw_amount] = amount
    redirect_to main_path
  rescue ActiveRecord::RecordNotUnique
    # ユニーク制約（user_id, date）が競合した場合も安全に案内
    redirect_to main_path, alert: I18n.t('draws.already_drawn_today', default: '本日はすでにガチャを回しています')
  end
end
