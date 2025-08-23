class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    # 今月を取得
    @month = params[:month].present? ? Date.parse(params[:month] + "-01") : Date.current.beginning_of_month
    month_range = @month.all_month

    # 今月分の抽選
    @draws = current_user.draws.where(date: month_range).order(:date)
    @sum_amount = @draws.sum(:amount)
    @sum_actual = @draws.sum { |d| d.actual_amount.presence || d.amount }
    @month_diff_total = @draws.sum { |d| (d.actual_amount || d.amount) - d.amount }

    # 全期間分（累計差額用）
    @all_draws = current_user.draws
    @cumulative_diff_total = @all_draws.sum { |d| (d.actual_amount || d.amount) - d.amount }
  end
end
