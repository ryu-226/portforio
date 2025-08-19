class BudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: [:edit, :update]

  def new
    year_month = Date.current.strftime("%Y-%m")
    existing_budget = current_user.budget_for(year_month)

    if existing_budget.nil? && params[:from_signup] != '1'
     return redirect_to new_budget_path(from_signup: '1')
    end

    if existing_budget
      redirect_to edit_budget_path
    else
      @budget = Budget.new(user: current_user, year_month: year_month)
    end
  end

  def edit
    unless @budget
      redirect_to new_budget_path, alert: "まだ条件を設定していません。まずは各種条件を設定してください。"
      return
    end
    set_remaining_status
  end

  def create
    year_month = Date.current.strftime("%Y-%m")
    @budget = Budget.new(budget_params.merge(user: current_user, year_month: year_month))

    if @budget.save
      if params[:from_signup] == "1"
        redirect_to main_path, notice: "条件を設定しました"
      else
        redirect_to mypage_path, notice: "条件を設定しました"
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to mypage_path, notice: "条件を更新しました"
    else
      set_remaining_status
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_budget
    @budget = current_user.budget_for(Date.current.strftime("%Y-%m"))
  end

  def budget_params
    params.require(:budget).permit(:monthly_budget, :draw_days, :min_amount, :max_amount)
  end

  def set_remaining_status
    month_range = Date.current.all_month
    used_count = current_user.draws.where(date: month_range).count
    used_sum = current_user.draws.where(date: month_range).sum(:amount)

    draw_days = @budget.draw_days
    monthly_budget = @budget.monthly_budget

    @remaining_days = draw_days.to_i - used_count
    @remaining_budget = monthly_budget.to_i - used_sum

    today = Date.current
    @used_count = used_count
    @drawn_today = current_user.draws.exists?(date: today)

    @remaining_calendar_days = (today..today.end_of_month).count
    @available_days = @remaining_calendar_days - (@drawn_today ? 1 : 0)
    @days_in_month = today.end_of_month.day
  end
end
