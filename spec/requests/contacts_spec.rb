require 'rails_helper'

RSpec.describe 'Contacts', type: :request do
  it '未入力は422' do
    post contact_path, params: { name: '', email: '', message: '' }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it '正しく入力すれば送信してリダイレクト（Mailerはスタブ）' do
    expect(ContactMailer).to receive_message_chain(:with, :inquiry_email, :deliver_now).and_return(true)
    post contact_path, params: { name: '太郎', email: 'taro@example.com', message: 'こんにちは' }
    expect(response).to have_http_status(:found)
  end
end
