require "rails_helper"

RSpec.describe "Draws", type: :request do
  describe "PATCH /draws/:id" do
    it "未ログインはログインへ" do
      draw = create(:draw)
      patch draw_path(draw), params: { actual_amount: 600 }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済 & 自分の draw なら更新できる" do
      user = create(:user)
      sign_in user
      draw = create(:draw, user:)
      patch draw_path(draw), params: { actual_amount: 650 }
      expect(response).to redirect_to(history_path)
      expect(draw.reload.actual_amount).to eq 650
    end

    it "他人の draw は見つからず 404 相当 (ActiveRecord::RecordNotFound)" do
      user = create(:user)
      other = create(:user)
      sign_in user
      draw = create(:draw, user: other)
      expect { patch draw_path(draw), params: { actual_amount: 650 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
