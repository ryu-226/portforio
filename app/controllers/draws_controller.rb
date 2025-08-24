class DrawsController < ApplicationController
  before_action :authenticate_user!, except: :show

  def show
    @draw = Draw.find(params[:id])

    @og_title = "めしガチャ結果"
    @og_desc  = "予算 #{@draw.amount.to_i}円"
    @og_image = helpers.image_url("ogp_default.png")
    @og_url   = draw_url(@draw)

    render :show
  rescue ActiveRecord::RecordNotFound
    render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
  end

  def update
    draw = current_user.draws.find(params[:id])
    if draw.update(actual_amount: params[:actual_amount])
      redirect_to history_path, notice: t('actual.save_success')
    else
      redirect_to history_path, alert: t('actual.save_failure')
    end
  end
end
