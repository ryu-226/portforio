require 'rails_helper'
require 'webmock/rspec'

RSpec.describe 'Places', type: :request do
  before do
    allow(ENV).to receive(:fetch).with('GOOGLE_PLACES_API_KEY').and_return('test-key')
  end

  it 'searchText 成功時は200でJSONを返す' do
    stub_request(:post, 'https://places.googleapis.com/v1/places:searchText')
      .to_return(status: 200, body: { places: [] }.to_json, headers: { 'Content-Type' => 'application/json' })

    post places_search_path, params: { textQuery: 'ramen' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to have_key('places')
  end

  it '無効JSONを返した場合はそのまま本文・ステータスを返す(JSON::ParserError分岐)' do
    stub_request(:post, %r{https://places\.googleapis\.com/v1/places:(searchText|searchNearby)})
      .to_return(status: 502, body: 'upstream oops', headers: { 'Content-Type' => 'text/plain' })

    post places_search_path, params: { textQuery: 'sushi' }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    expect(response.status).to eq 502
    expect(response.body).to eq 'upstream oops'
  end
end
