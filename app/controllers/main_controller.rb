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

    @draw_message = nil
    return unless @draw

    # 帯境界は DrawPicker に揃える
    picker = DrawPicker.new(
      min: @budget.min_amount, max: @budget.max_amount,
      remaining_days: @remaining_days, remaining_budget: @remaining_budget
    )
    band = picker.classify(@draw.amount)

    @draw_message =
      case band
      when :low  then t('main.draw_messages.low').sample
      when :mid  then t('main.draw_messages.mid').sample
      when :high then t('main.draw_messages.high').sample
      end
  end

  def draw
    today = Time.zone.today
    budget = current_user.budget_for(today.strftime('%Y-%m'))

    unless budget
      redirect_to new_budget_path, alert: t('draws.need_budget')
      return
    end

    if current_user.draws.exists?(date: today)
      redirect_to main_path, alert: t('draws.already_drawn_today')
      return
    end

    month_range = today.all_month
    drawn_count = current_user.draws.where(date: month_range).count
    drawn_sum = current_user.draws.where(date: month_range).sum(:amount)
    remaining_days = budget.draw_days.to_i - drawn_count
    remaining_budget = budget.monthly_budget.to_i - drawn_sum

    if remaining_days <= 0
      redirect_to main_path, alert: t('draws.days_limit')
      return
    end

    if (remaining_days * budget.min_amount.to_i) > remaining_budget ||
       (remaining_days * budget.max_amount.to_i) < remaining_budget
      redirect_to edit_budget_path, alert: t('draws.infeasible_combo')
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
      redirect_to main_path, alert: t('draws.already_drawn_today')
      return
    end

    flash[:draw_amount] = amount
    redirect_to main_path
  rescue ActiveRecord::RecordNotUnique
    # ユニーク制約（user_id, date）が競合した場合も安全に案内
    redirect_to main_path, alert: t('draws.already_drawn_today')
  end
end
