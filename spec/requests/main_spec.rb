require "rails_helper"

RSpec.describe "Main", type: :request do
  let(:user) { create(:user) }

  around { |ex| travel_to(Time.zone.local(2025, 1, 15, 12)) { ex.run } }

  describe "GET /main" do
    it "ログイン済 & 予算未設定でも 200" do
      sign_in user
      get main_path
      expect(response).to have_http_status(:ok)
    end

    it "ログイン済 & 予算ありでも 200" do
      sign_in user
      create(:budget, user: user, monthly_budget: 12_000, draw_days: 10, min_amount: 500, max_amount: 1_500)
      get main_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /main/draw" do
    it "未ログインはログインへ" do
      post draw_main_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "予算未設定なら /budget/new にリダイレクト" do
      sign_in user
      post draw_main_path
      expect(response).to redirect_to(new_budget_path)
    end

    it "予算あり・未抽選なら作成され main へリダイレクト" do
      sign_in user
      create(:budget, user:, monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500)
      expect { post draw_main_path }.to change { user.draws.count }.by(1)
      expect(response).to redirect_to(main_path)
    end

    it "同日に既に抽選済なら main へリダイレクト (作成されない)" do
      sign_in user
      create(:budget, user:, monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500)
      create(:draw, user:, date: Date.current)
      expect { post draw_main_path }.not_to(change { user.draws.count })
      expect(response).to redirect_to(main_path)
    end
  end
end
