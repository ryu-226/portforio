require 'rails_helper'
require 'ostruct'

RSpec.describe User, '.from_omniauth' do
  def auth_hash(email: 'g@example.com', name: 'G User', image: 'http://img', provider: 'google_oauth2', uid: 'uid-1')
    OpenStruct.new(provider: provider, uid: uid, info: OpenStruct.new(email: email, name: name, image: image))
  end

  it '既存ユーザーがいれば provider/uid/image を更新して返す' do
    u = create(:user, email: 'g@example.com')
    res = User.from_omniauth(auth_hash(email: 'g@example.com', uid: 'new-uid'))
    expect(res).to eq u
    expect(u.reload.uid).to eq 'new-uid'
    expect(u.provider).to eq 'google_oauth2'
  end

  it '存在しないメールなら新規作成し、確認をスキップする' do
    res = described_class.from_omniauth(auth_hash(email: 'new@example.com'))
    expect(res).to be_persisted
    expect(res.confirmed_at).to be_present
    expect(res.provider).to eq 'google_oauth2'
    expect(res.uid).to eq 'uid-1'
  end

  it 'メールが空なら nil を返す' do
    res = described_class.from_omniauth(auth_hash(email: ''))
    expect(res).to be_nil
  end
end
