require "rails_helper"

RSpec.describe "Budgets create", type: :request do
  let(:user) { create(:user) }

  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }
  before { sign_in user }

  it "from_signup=1 なら作成成功後 main へ" do
    post budget_path, params: { from_signup: "1", budget: { monthly_budget: 12_000, draw_days: "10", min_amount: 500, max_amount: 1_500 } }
    expect(response).to redirect_to(main_path)
  end

  it "monthly_budget が max_amount 以下だと 422" do
    post budget_path, params: { from_signup: "1", budget: { monthly_budget: 1_500, draw_days: "10", min_amount: 500, max_amount: 1_500 } }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it "from_signup が無い場合は作成後 mypage へ" do
    post budget_path, params: { budget: { monthly_budget: 12_000, draw_days: "10", min_amount: 500, max_amount: 1500 } }
    expect(response).to redirect_to(mypage_path)
  end
end
