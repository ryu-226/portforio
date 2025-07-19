class HistoryController < ApplicationController
  before_action :require_login

  def index
    # 今月を取得（今後はパラメータで月変更可に拡張）
    @month = params[:month].present? ? Date.parse(params[:month] + "-01") : Date.current.beginning_of_month
    # その月の範囲
    month_range = @month.beginning_of_month..@month.end_of_month

    # ログインユーザーのその月のガチャ履歴
    @draws = current_user.draws.where(date: month_range).order(:date)

    # 今月の抽選金額合計
    @sum_amount = @draws.sum(:amount)

    # 実際使った金額合計（未入力はamountと同額として合算）
    @sum_actual = @draws.sum { |d| d.actual_amount.present? ? d.actual_amount : d.amount }

  end
end
