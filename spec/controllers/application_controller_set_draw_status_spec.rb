require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    before_action :authenticate_user!
    def index = render(plain: 'ok')
  end

  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  let(:user) { create(:user) }

  before { sign_in user }

  it '予算あり：今月の使用数/使用額から残日数・残予算を計算する' do
    create(:budget, user: user, draw_days: '10', monthly_budget: 12_000, min_amount: 500, max_amount: 1500)
    base = Date.current.beginning_of_month
    create(:draw, user: user, date: base + 0, amount: 1_000)
    create(:draw, user: user, date: base + 1, amount: 1_500)
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:drawn_count)).to eq 2
    expect(assigns(:drawn_sum)).to eq 2_500
    expect(assigns(:remaining_days)).to eq(10 - 2)
    expect(assigns(:remaining_budget)).to eq(12_000 - 2_500)
  end

  it '予算なし：残日数/残予算は nil' do
    get :index
    expect(response).to have_http_status(:ok)
    expect(assigns(:remaining_days)).to be_nil
    expect(assigns(:remaining_budget)).to be_nil
  end
end
