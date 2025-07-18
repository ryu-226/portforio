class MainController < ApplicationController
  before_action :require_login

  def index
    @draw = current_user.draws.find_by(date: Date.current)
    @budget = current_user.budget
    unless @budget
      redirect_to new_budget_path, alert: "まずは予算を設定してください"
      return
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

    # MVP：単純に min_amount〜max_amount で乱数
    amount = rand(budget.min_amount..budget.max_amount)

    @draw = current_user.draws.create!(
      date: Date.current,
      amount: amount
    )

    flash[:draw_amount] = amount
    redirect_to main_path
  end
end
