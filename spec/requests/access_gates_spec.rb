require "rails_helper"

RSpec.describe "Access gates", type: :request do
  it "root は 200 (公開)" do
    get root_path
    expect(response).to have_http_status(:ok)
  end

  it "static terms/privacy は 200 (公開)" do
    get terms_path
    expect(response).to have_http_status(:ok)
    get privacy_path
    expect(response).to have_http_status(:ok)
  end

  it "未ログインだと main/history/search/mypage/budget はログインへ" do
    get main_path
    expect(response).to redirect_to(new_user_session_path)
    get history_path
    expect(response).to redirect_to(new_user_session_path)
    get search_path
    expect(response).to redirect_to(new_user_session_path)
    get mypage_path
    expect(response).to redirect_to(new_user_session_path)
    get new_budget_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it "draws#show は公開で 200 / 不正IDは404" do
    draw = create(:draw)
    get draw_path(draw)
    expect(response).to have_http_status(:ok)
    get draw_path(-1)
    expect(response).to have_http_status(:not_found)
  end
end
