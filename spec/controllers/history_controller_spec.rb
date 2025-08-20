require "rails_helper"

RSpec.describe HistoryController, type: :controller do
  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  let(:user) { create(:user) }
  before { sign_in user }

  it "month 指定なしは当月を集計する" do
    base = Date.current.beginning_of_month
    create(:draw, user: user, date: base + 0, amount: 1_000, actual_amount:  800)
    create(:draw, user: user, date: base + 1, amount: 1_000, actual_amount: 1200)
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:sum_amount)).to  eq 2_000
    expect(assigns(:sum_actual)).to  eq 2_000
    expect(assigns(:month_diff_total)).to eq 0
    expect(assigns(:cumulative_diff_total)).to eq 0
  end

  it "month 指定ありはその月を集計する" do
    jan = Date.new(2025, 1, 1)
    create(:draw, user: user, date: jan + 0, amount: 1_000, actual_amount:  900)
    create(:draw, user: user, date: jan + 1, amount: 2_000, actual_amount: 2500)
    create(:draw, user: user, date: Date.new(2024,12,1), amount: 1000, actual_amount: 800)
    get :index, params: { month: "2025-01" }
    expect(response).to have_http_status(:ok)
    expect(assigns(:sum_amount)).to eq 3_000
    expect(assigns(:sum_actual)).to eq 3_400
    expect(assigns(:month_diff_total)).to eq 400
    expect(assigns(:cumulative_diff_total)).to eq 200
  end
end
