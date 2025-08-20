require 'rails_helper'

RSpec.describe User, type: :model do
  it '英字と数字の両方が必要' do
    u1 = build(:user, email: 'a1@example.com', password: 'aaaaaa')
    u2 = build(:user, email: 'b2@example.com', password: '111111')
    u3 = build(:user, email: 'c3@example.com', password: 'abc123')
    expect(u1).to be_invalid
    expect(u2).to be_invalid
    expect(u3).to be_valid
  end
end
