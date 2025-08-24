class HistoryController < ApplicationController
  before_action :authenticate_user!

  def index
    @month = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month

    rel = current_user.draws.in_month(@month).order(:date)
    @draws = rel
    @sum_amount = rel.sum(:amount)
    @sum_actual = rel.sum("COALESCE(actual_amount, amount)")
    @month_diff_total = @sum_amount - @sum_actual
    @cumulative_diff_total = current_user.draws.sum("amount - COALESCE(actual_amount, amount)")
  end
end
