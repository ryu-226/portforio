require 'rails_helper'

RSpec.describe 'Contacts new', type: :request do
  it 'GET /contact/new は 200' do
    get new_contact_path
    expect(response).to have_http_status(:ok)
  end
end
