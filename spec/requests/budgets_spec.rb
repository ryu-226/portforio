require "rails_helper"

RSpec.describe "Budgets", type: :request do
  let(:user) { create(:user) }

  describe "GET /budget/new" do
    it "未ログインはログインへ" do
      get new_budget_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済 & 当月予算がなく from_signup無しなら from_signup=1 へリダイレクト" do
      sign_in user
      get new_budget_path
      expect(response).to redirect_to(new_budget_path(from_signup: "1"))
    end

    it "ログイン済 & 既に当月予算があれば edit へ" do
      sign_in user
      create(:budget, user:)
      get new_budget_path(from_signup: "1")
      expect(response).to redirect_to(edit_budget_path)
    end

    it "ログイン済 & 予算未設定 + from_signup=1 なら 200" do
      sign_in user
      get new_budget_path(from_signup: "1")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /budget" do
    it "未ログインはログインへ" do
      post budget_path, params: { budget: { monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500 } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済 & from_signup=1 なら作成成功後 main へ" do
      sign_in user
      post budget_path, params: { from_signup: "1", budget: { monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500 } }
      expect(response).to redirect_to(main_path)
    end

    it "ログイン済 & from_signup無しなら作成成功後 mypage へ" do
      sign_in user
      post budget_path, params: { budget: { monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500 } }
      expect(response).to redirect_to(mypage_path)
    end
  end

  describe "GET /budget/edit" do
    it "ログイン済 & 予算未設定なら new へ" do
      sign_in user
      get edit_budget_path
      expect(response).to redirect_to(new_budget_path)
    end

    it "ログイン済 & 予算ありなら 200" do
      sign_in user
      create(:budget, user:)
      get edit_budget_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /budget" do
    it "ログイン済 & 予算更新で mypage へ" do
      sign_in user
      create(:budget, user:, monthly_budget: 3000, draw_days: "3", min_amount: 500, max_amount: 1500)
      patch budget_path, params: { budget: { monthly_budget: 5000, draw_days: "4", min_amount: 400, max_amount: 1600 } }
      expect(response).to redirect_to(mypage_path)
    end
  end
end
