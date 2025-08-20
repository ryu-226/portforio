require "rails_helper"

RSpec.describe "Budgets update success", type: :request do
  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  it "更新成功で mypage にリダイレクト" do
    user = create(:user)
    sign_in user
    budget = create(:budget, user: user, draw_days: "5", monthly_budget: 7000, min_amount: 500, max_amount: 1500)
    patch budget_path, params: { budget: { draw_days: "6" } }
    expect(response).to redirect_to(mypage_path)
    expect(budget.reload.draw_days.to_i).to eq 6
  end
end
