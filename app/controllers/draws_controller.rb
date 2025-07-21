class DrawsController < ApplicationController
  before_action :require_login

  def update
    draw = current_user.draws.find(params[:id])
    if draw.update(actual_amount: params[:actual_amount])
      redirect_back fallback_location: history_path, notice: "金額を保存しました"
    else
      redirect_back fallback_location: history_path, alert: "保存に失敗しました"
    end
  end
end
