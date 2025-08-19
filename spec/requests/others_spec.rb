require "rails_helper"

RSpec.describe "Other protected pages", type: :request do
  let(:user) { create(:user) }

  it "history はログイン必須" do
    get history_path
    expect(response).to redirect_to(new_user_session_path)
    sign_in user
    get history_path
    expect(response).to have_http_status(:ok)
  end

  it "mypage はログイン必須" do
    get mypage_path
    expect(response).to redirect_to(new_user_session_path)
    sign_in user
    get mypage_path
    expect(response).to have_http_status(:ok)
  end

  it "search はログイン必須" do
    get search_path
    expect(response).to redirect_to(new_user_session_path)
    sign_in user
    get search_path
    expect(response).to have_http_status(:ok)
  end
end
