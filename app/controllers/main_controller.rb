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

    month_range = Date.current.beginning_of_month..Date.current.end_of_month
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

    if @draw
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
    today = Time.zone.today
    budget = current_user.budget_for(today.strftime('%Y-%m'))
    
    unless budget
      redirect_to new_budget_path, alert: "まずは予算を設定してください"
      return
    end

    if current_user.draws.exists?(date: today)
      redirect_to main_path, alert: "本日はすでにガチャを回しています"
      return
    end

    month_range = today.beginning_of_month..today.end_of_month
    month_draws = current_user.draws.where(date: month_range)
    drawn_count = month_draws.count
    drawn_sum = month_draws.sum(:amount)

    remaining_days = budget.draw_days.to_i - drawn_count
    remaining_budget = budget.monthly_budget.to_i - drawn_sum

    if remaining_days <= 0
      redirect_to main_path, alert: "今月のガチャできる日数が上限に達しました。設定を見直してください。"
      return
    end

    if (remaining_days * budget.min_amount.to_i) > remaining_budget ||
       (remaining_days * budget.max_amount.to_i) < remaining_budget
      redirect_to edit_budget_path, alert: "残り予算と残りガチャ日数に合わない条件です。設定を見直してください。"
      return
    end

    # ===== ここから金額決定ロジック =====
    min_amt = budget.min_amount.to_i
    max_amt = budget.max_amount.to_i

    # 残り回数・残り予算に矛盾しない実現可能レンジ
    min_feasible = [min_amt, remaining_budget - max_amt * (remaining_days - 1)].max
    max_feasible = [max_amt, remaining_budget - min_amt * (remaining_days - 1)].min

    ceil10  = ->(n) { ((n + 9) / 10) * 10 }
    floor10 = ->(n) { (n / 10) * 10 }

    min10 = ceil10.call(min_feasible)
    max10 = floor10.call(max_feasible)

    pick_from_band = lambda do |start_yen, end_yen|
      ticks = (end_yen - start_yen) / 10 + 1
      idx   = rand(ticks)
      start_yen + idx * 10
    end

    if remaining_days == 1
      # 最終日は残り予算を10円刻みに切り下げ（数十円余りOK）、かつ min/max を超えない
      amount = floor10.call(remaining_budget).clamp(min_feasible, max_feasible)
    else
      # 帯の“幅”は Mid 広め（25%/50%/25%）、出やすさは Low/High 厚め（40%/20%/40%）
      width_low, width_mid, width_high = 0.35, 0.30, 0.35
      w_low,   w_mid,   w_high         = 0.30, 0.40, 0.30

      if min10 > max10
        # 10円グリッドに乗らないほど狭い → 近い10円に丸めてクランプ
        amount = (min_feasible.to_f / 10).round * 10
        amount = amount.clamp(min_feasible, max_feasible)
      else
        ticks_total = (max10 - min10) / 10 + 1

        low_ticks  = [(ticks_total * width_low ).floor, 1].max
        mid_ticks  = [(ticks_total * width_mid ).floor, 1].max
        high_ticks =  ticks_total - low_ticks - mid_ticks
        if high_ticks < 1
          take = 1 - high_ticks
          reduce_mid = [take, mid_ticks - 1].min
          mid_ticks -= reduce_mid
          take -= reduce_mid
          low_ticks -= [take, low_ticks - 1].min
          high_ticks = 1
        end

        low_min  = min10
        low_max  = low_min + (low_ticks - 1) * 10
        mid_min  = low_max + 10
        mid_max  = mid_min + (mid_ticks - 1) * 10
        high_min = mid_max + 10
        high_max = max10

        r = rand
        band = if r < w_low
                :low
              elsif r < (w_low + w_mid)
                :mid
              else
                :high
              end

        range =
          case band
          when :low  then (low_min  <= low_max  ? [low_min,  low_max]  : [min10, max10])
          when :mid  then (mid_min  <= mid_max  ? [mid_min,  mid_max]  : [min10, max10])
          when :high then (high_min <= high_max ? [high_min, high_max] : [min10, max10])
          end

        amount = pick_from_band.call(*range)
      end
    end

    # 念のためクランプ
    amount = amount.clamp(min_feasible, max_feasible)

    @draw = current_user.draws.create!(date: today, amount: amount)
    flash[:draw_amount] = amount
    redirect_to main_path
  end
end
