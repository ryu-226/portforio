require "rails_helper"

RSpec.describe MainController, type: :controller do
  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  let(:user) { create(:user) }
  before { sign_in user }

  it "low 帯のメッセージを設定する（amount <= low_max）" do
    create(:budget, user: user, min_amount: 500, max_amount: 1500)
    create(:draw, user: user, date: Date.current, amount: 600)
    allow_any_instance_of(Array).to receive(:sample).and_return("LOW_MSG")
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:draw_message)).to eq "LOW_MSG"
  end

  it "mid 帯のメッセージを設定する" do
    create(:budget, user: user, min_amount: 500, max_amount: 1500)
    create(:draw,   user: user, date: Date.current, amount: 1000)
    allow_any_instance_of(Array).to receive(:sample).and_return("MID_MSG")
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:draw_message)).to eq "MID_MSG"
    end

  it "high 帯のメッセージを設定する（amount >= high_min）" do
    create(:budget, user: user, min_amount: 500, max_amount: 1500)
    create(:draw,   user: user, date: Date.current, amount: 1400)
    allow_any_instance_of(Array).to receive(:sample).and_return("HIGH_MSG")
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:draw_message)).to eq "HIGH_MSG"
  end
end
