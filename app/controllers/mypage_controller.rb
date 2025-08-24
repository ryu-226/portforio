class MypageController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draw_status, only: [:index]

  def index
    @user = current_user
    ym = Date.current.strftime('%Y-%m')
    @budget = @user.budget_for(ym)
    @member_days = (Time.zone.today - @user.created_at.in_time_zone('Asia/Tokyo').to_date).to_i + 1
    @gacha_count = @user.draws.count

    if @budget
      stats = DrawStats.for(user: @user, budget: @budget, date: Date.current)
      @remaining_days = stats.remaining_days
      @remaining_budget = stats.remaining_budget
    end

    rel = current_user.draws.where.not(actual_amount: nil)
    @save_days = rel.where("actual_amount < amount").count
    @over_days = rel.where("actual_amount > amount").count
  end
end
