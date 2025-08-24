class MainController < ApplicationController
  before_action :authenticate_user!

  def index
    @budget = current_user.budget_for(Date.current.strftime('%Y-%m'))
    @draw = current_user.draws.find_by(date: Date.current)
    return (@remaining_days = @remaining_budget = @draw_message = nil) if @budget.blank?

    stats = DrawStats.for(user: current_user, budget: @budget, date: Date.current)
    @remaining_days = stats.remaining_days
    @remaining_budget = stats.remaining_budget
    return unless @draw

    band = DrawPicker.new(
      min: @budget.min_amount, max: @budget.max_amount,
      remaining_days: @remaining_days, remaining_budget: @remaining_budget
    ).classify(@draw.amount)

    @draw_message = t("main.draw_messages.#{band}").sample
  end

  def draw
    today = Time.zone.today
    budget = current_user.budget_for(today.strftime('%Y-%m'))
    return redirect_to(new_budget_path, alert: t('draws.need_budget')) unless budget

    return redirect_to(main_path, alert: t('draws.already_drawn_today')) if current_user.draws.exists?(date: today)

    stats = DrawStats.for(user: current_user, budget: budget, date: today)
    return redirect_to(main_path, alert: t('draws.days_limit')) if stats.remaining_days <= 0
    return redirect_to(edit_budget_path, alert: t('draws.infeasible_combo')) unless DrawPicker.feasible?(
      min: budget.min_amount, max: budget.max_amount,
      remaining_days: stats.remaining_days, remaining_budget: stats.remaining_budget
    )

    amount = DrawPicker.new(
      min: budget.min_amount, max: budget.max_amount,
      remaining_days: stats.remaining_days, remaining_budget: stats.remaining_budget
    ).pick

    already_drawn = false
    current_user.with_lock do
      already_drawn = current_user.draws.exists?(date: today)
      @draw = current_user.draws.create!(date: today, amount: amount) unless already_drawn
    end
    return redirect_to(main_path, alert: t('draws.already_drawn_today')) if already_drawn

    flash[:draw_amount] = amount
    redirect_to main_path
  rescue ActiveRecord::RecordNotUnique
    redirect_to main_path, alert: t('draws.already_drawn_today')
  end
end
