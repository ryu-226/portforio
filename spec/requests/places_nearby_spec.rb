require "rails_helper"

RSpec.describe "Places (nearby)", type: :request do
  before do
    allow(ENV).to receive(:fetch).with("GOOGLE_PLACES_API_KEY").and_return("test-key")
    stub_request(:post, "https://places.googleapis.com/v1/places:searchNearby")
      .to_return(status: 200, body: { places: [{ id: "p1" }] }.to_json, headers: { "Content-Type" => "application/json" })
  end

  it "textQuery 無しなら searchNearby に投げて 200" do
    post places_search_path, params: { locationBias: { circle: { center: { latitude: 35.0, longitude: 139.0 }, radius: 1000 } } }.to_json, headers: { "CONTENT_TYPE" => "application/json" }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to have_key("places")
  end
end
