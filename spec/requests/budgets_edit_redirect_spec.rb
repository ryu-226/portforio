require "rails_helper"

RSpec.describe "Budgets edit redirect", type: :request do
  it "当月予算が無ければ /budget/new にリダイレクト" do
    user = create(:user)
    sign_in user
    get edit_budget_path
    expect(response).to redirect_to(new_budget_path)
  end
end
