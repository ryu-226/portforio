require 'rails_helper'

RSpec.describe Draw, type: :model do
  let(:user) { create(:user) }

  around { |ex| travel_to(Time.zone.local(2025, 1, 10, 12)) { ex.run } }

  it '同一ユーザーの同日重複は無効 (モデルバリデーション)' do
    create(:draw, user:, date: Date.current, amount: 800)
    d2 = build(:draw, user:, date: Date.current, amount: 900)
    expect(d2).to be_invalid
    expect(d2.errors[:date]).to be_present
  end

  it 'amount は正の整数が必須' do
    d = build(:draw, user:, amount: 0)
    expect(d).to be_invalid
    expect(d.errors[:amount]).to be_present
  end

  it 'actual_amount は nil または正の整数' do
    d = build(:draw, user:, amount: 800, actual_amount: -1)
    expect(d).to be_invalid
    expect(d.errors[:actual_amount]).to be_present
    d2 = build(:draw, user:, amount: 800, actual_amount: nil)
    expect(d2).to be_valid
  end
end
