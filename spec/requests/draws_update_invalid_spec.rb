require "rails_helper"

RSpec.describe "Draws update invalid", type: :request do
  it "actual_amount が不正だと保存されず history に戻る" do
    user = create(:user)
    sign_in user
    draw = create(:draw, user:, actual_amount: 800)
    patch draw_path(draw), params: { actual_amount: 0 }
    expect(response).to redirect_to(history_path)
    expect(draw.reload.actual_amount).to eq 800
  end
end
