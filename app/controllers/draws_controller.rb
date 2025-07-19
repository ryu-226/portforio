class DrawsController < ApplicationController
  before_action :require_login

  def update_actual_amount
    draw = current_user.draws.find(params[:id])
    if draw.update(actual_amount: params[:actual_amount])
      flash[:notice] = "実際に使った金額を保存しました"
    else
      flash[:alert] = "保存に失敗しました"
    end
    redirect_back fallback_location: history_path
  end
end