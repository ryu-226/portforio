require 'rails_helper'

RSpec.describe 'Budgets new redirect', type: :request do
  let(:user) { create(:user) }

  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  it '当月予算なし & from_signup無 → /budget/new?from_signup=1 にリダイレクト' do
    sign_in user
    get new_budget_path
    expect(response).to redirect_to(new_budget_path(from_signup: '1'))
  end
end
