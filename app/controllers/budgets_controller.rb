class BudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: [:edit, :update]

  def new
    year_month = Date.current.strftime("%Y-%m")
    existing_budget = current_user.budget_for(year_month)

    return redirect_to new_budget_path(from_signup: '1') if existing_budget.nil? && params[:from_signup] != '1'
    return redirect_to edit_budget_path if existing_budget

    @budget = Budget.new(user: current_user, year_month: year_month)
  end

  def edit
    unless @budget
      redirect_to new_budget_path, alert: t('budgets.not_have_set')
      return
    end
    set_remaining_status
  end

  def create
    year_month = Date.current.strftime("%Y-%m")
    @budget = Budget.new(budget_params.merge(user: current_user, year_month: year_month))
    return render(:new, status: :unprocessable_entity) unless @budget.save

    redirect_to after_create_path, notice: t('budgets.set_conditions')
  end

  def update
    if @budget.update(budget_params)
      redirect_to mypage_path, notice: t('budgets.update_set')
    else
      set_remaining_status
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def after_create_path
    params[:from_signup] == "1" ? main_path : mypage_path
  end

  def set_budget
    @budget = current_user.budget_for(Date.current.strftime("%Y-%m"))
  end

  def budget_params
    params.require(:budget).permit(:monthly_budget, :draw_days, :min_amount, :max_amount)
  end

  def set_remaining_status
    stats = DrawStats.for(user: current_user, budget: @budget, date: Date.current)

    @remaining_days = stats.remaining_days
    @remaining_budget = stats.remaining_budget

    today = Date.current
    @used_count = stats.drawn_count
    @drawn_today = current_user.draws.exists?(date: today)
    @days_in_month = today.end_of_month.day

    @remaining_calendar_days = (today..today.end_of_month).count
    @available_days = @remaining_calendar_days - (@drawn_today ? 1 : 0)
  end
end
