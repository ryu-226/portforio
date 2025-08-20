require 'rails_helper'

RSpec.describe 'Main#draw edges', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it '残り予算が0なら作成されず main へ' do
    travel_to(Time.zone.local(2025, 1, 15, 12)) do
      create(:budget, user:, draw_days: '3', min_amount: 500, max_amount: 1500, monthly_budget: 3_000)
      base = Date.current.beginning_of_month
      create(:draw, user:, date: base + 0, amount: 800)
      create(:draw, user:, date: base + 1, amount: 900)
      create(:draw, user:, date: base + 2, amount: 1_000)
      expect { post draw_main_path }.not_to change(user.draws, :count)
      expect(response).to redirect_to(main_path)
    end
  end

  it '残り予算と残り日数の条件が不整合なら edit_budget へ' do
    travel_to(Time.zone.local(2025, 1, 15, 12)) do
      create(:budget, user:, draw_days: '2', min_amount: 800, max_amount: 900, monthly_budget: 1_700)
      create(:draw, user:, date: Date.current.beginning_of_month, amount: 1_000)
      expect { post draw_main_path }.not_to change(user.draws, :count)
      expect(response).to redirect_to(edit_budget_path)
    end
  end

  it '最終日は残り予算を10円刻みでそのまま採用' do
    travel_to(Time.zone.local(2025, 1, 31, 12)) do
      base = Date.current.beginning_of_month
      9.times { |i| create(:draw, user:, date: base + i, amount: 1_200) }
      create(:budget, user:, draw_days: '10', min_amount: 500, max_amount: 1500, monthly_budget: 12_000)
      expect { post draw_main_path }.to change(user.draws, :count).by(1)
      created = user.draws.order(:created_at).last
      expect(created.amount).to eq(1_200)
      expect(response).to redirect_to(main_path)
    end
  end
end
