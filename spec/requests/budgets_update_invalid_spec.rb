require "rails_helper"

RSpec.describe "Budgets update invalid", type: :request do
  it "既に使った回数より draw_days を小さくすると422" do
    travel_to(Time.zone.local(2025, 1, 15, 12)) do
      user = create(:user)
      sign_in user
      budget = create(:budget, user:, draw_days: "5", monthly_budget: 5000, min_amount: 500, max_amount: 1500)
      base = Date.current.beginning_of_month
      3.times { |i| create(:draw, user:, date: base + i, amount: 800) }
      patch budget_path, params: { budget: { draw_days: "2" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
