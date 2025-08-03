class MypageController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draw_status, only: [:index]

  def index
    @user = current_user
    current_year_month = Date.current.strftime('%Y-%m')
    @budget = @user.budget_for(current_year_month)
    @member_days = (Time.zone.today - @user.created_at.in_time_zone('Asia/Tokyo').to_date).to_i + 1
    @gacha_count = @user.draws.count

    if @budget
      month_range = Date.current.beginning_of_month..Date.current.end_of_month
      used_count = @user.draws.where(date: month_range).count
      used_sum = @user.draws.where(date: month_range).sum(:amount)

      @remaining_days = @budget.draw_days.to_i - used_count
      @remaining_budget = @budget.monthly_budget.to_i - used_sum
    end
  end
end
