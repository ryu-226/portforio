class BudgetsController < ApplicationController
  before_action :require_login
  before_action :set_budget, only: [:edit, :update]

  def new
    if current_user.budget
      redirect_to edit_budget_path
    else
      @budget = current_user.build_budget
    end
  end

  def create
    @budget = current_user.build_budget(budget_params)
    if @budget.save
      redirect_to mypage_path, notice: "条件を設定しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @budget
      redirect_to new_budget_path, alert: "まだ条件を設定していません。まずは各種条件を設定してください。"
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to mypage_path, notice: "条件を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_budget
    @budget = current_user.budget
  end

  def budget_params
    params.require(:budget).permit(:monthly_budget, :draw_days, :min_amount, :max_amount)
  end

  def require_login
    redirect_to login_path, alert: "ログインしてください" unless logged_in?
  end
end
