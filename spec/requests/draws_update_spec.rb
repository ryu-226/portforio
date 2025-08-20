require 'rails_helper'

RSpec.describe 'Draws update', type: :request do
  it 'actual_amount の更新に成功すると history にリダイレクト' do
    user = create(:user)
    sign_in user
    draw = create(:draw, user: user, actual_amount: nil)
    patch draw_path(draw), params: { actual_amount: 1234 }
    expect(response).to redirect_to(history_path)
    expect(draw.reload.actual_amount).to eq 1234
  end
end
