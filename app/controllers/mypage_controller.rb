class MypageController < ApplicationController
  before_action :require_login

  def index
    @user = current_user
    @budget = @user.budget
    @member_days = (Time.zone.today - @user.created_at.in_time_zone('Asia/Tokyo').to_date).to_i    
    
    # ガチャ回数ダミー
    @gacha_count = 0

    # LINE通知ダミー
    @line_status = "未連携"
  end
end
