require "rails_helper"

RSpec.describe Budget, type: :model do
  let(:user) { create(:user) }

  around do |ex|
    travel_to(Time.zone.local(2025, 1, 15, 12, 0, 0)) { ex.run }
  end

  def build_valid_budget(overrides = {})
    today = Date.current
    remaining_days = (today..today.end_of_month).count
    days = [[remaining_days - 1, 1].max, 10].min
    min = 500
    max = 1500
    monthly = [min * days + ((max - min) * days) / 2, max + 1].max

    Budget.new({
      user: user,
      draw_days: days.to_s,
      min_amount: min,
      max_amount: max,
      monthly_budget: monthly
    }.merge(overrides))
  end

  it "有効な属性なら作成できる" do
    b = build_valid_budget
    expect(b).to be_valid, b.errors.full_messages.to_sentence
    expect { b.save! }.to change(Budget, :count).by(1)
  end

  it "同一ユーザー×同一year_monthは一意" do
    b1 = build_valid_budget(year_month: "2025-01")
    expect(b1.save).to eq true
    b2 = build_valid_budget(year_month: "2025-01")
    expect(b2).to be_invalid
    expect(b2.errors[:year_month]).to be_present
  end

  it "max_amount は min_amount より大きくないと無効" do
    b = build_valid_budget(min_amount: 1000, max_amount: 1000)
    expect(b).to be_invalid
    expect(b.errors[:max_amount]).to be_present
  end

  it "monthly_budget が 1日の max_amount 以下だと無効 (実装仕様)" do
    b = build_valid_budget(max_amount: 1500, monthly_budget: 1500)
    expect(b).to be_invalid
    expect(b.errors[:monthly_budget]).to be_present
  end

  it "draw_days が今月日数を超えると無効" do
    b = build_valid_budget(draw_days: "40")
    expect(b).to be_invalid
    expect(b.errors[:draw_days]).to be_present
  end

  it "既に使った回数より draw_days を小さく更新できない" do
    b = build_valid_budget
    b.save!
    create(:draw, user:, date: Date.current.beginning_of_month, amount: 800)
    create(:draw, user:, date: Date.current.beginning_of_month + 1, amount: 1000)
    b.draw_days = "1"
    expect(b).to be_invalid
    expect(b.errors[:draw_days]).to be_present
  end

  it "draw_days は「既に使った回数＋今日から月末の残日数」を超えられない" do
    today = Date.current
    available = (today..today.end_of_month).count
    b = build_valid_budget(draw_days: (available + 1).to_s)
    expect(b).to be_invalid
    expect(b.errors[:draw_days]).to be_present
  end

  it "残り予算が 残り回数×min 未満なら無効" do
    b = build_valid_budget(draw_days: "2", min_amount: 1000, max_amount: 1500, monthly_budget: 2500)
    b.save!
    create(:draw, user:, date: Date.current.beginning_of_month, amount: 1800)
    expect(b.reload).to be_invalid
    expect(b.errors[:monthly_budget]).to be_present
  end

  it "残り予算が 残り回数×max を超えると無効" do
    b = build_valid_budget(draw_days: "2", min_amount: 500, max_amount: 1000, monthly_budget: 2000)
    expect(b).to be_valid, b.errors.full_messages.to_sentence
    b.save!
    create(:draw, user:, date: Date.current.beginning_of_month, amount: 100)
    expect(b.reload).to be_invalid
    expect(b.errors[:monthly_budget]).to be_present
  end

  it "今日すでにガチャ済みの場合、draw_days の上限は (used + 残り日数-1) を超えられない" do
    user = create(:user)
    create(:draw, user:, date: Date.current, amount: 800)
    used = 1
    available_days = (Date.current..Date.current.end_of_month).count - 1
    over = used + available_days + 1
    b = Budget.new(user:, draw_days: over.to_s, min_amount: 500, max_amount: 1500, monthly_budget: 10_000)
    expect(b).to be_invalid
    expect(b.errors[:draw_days]).to be_present
  end
end
