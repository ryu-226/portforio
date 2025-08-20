require 'rails_helper'

RSpec.describe User, '#password_required?' do
  it 'provider/uid があればパスワード無しでも保存できる' do
    u = User.new(email: 'oauth@example.com', nickname: 'OAuth', provider: 'google_oauth2', uid: 'uid-xyz')
    u.skip_confirmation_notification!
    expect(u.save).to be true
  end
end
