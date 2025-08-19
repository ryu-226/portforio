require "rails_helper"

RSpec.describe Budget, type: :model do
  it "有効な属性なら作成できる" do
    budget = build(:budget)
    expect(budget).to be_valid, budget.errors.full_messages.to_sentence
    expect { budget.save! }.to change(Budget, :count).by(1)
  end

  it "同一ユーザー×同一year_monthは一意（DB or モデルで検出）" do
    user = create(:user)
    create(:budget, user:, year_month: "2025-08")
    expect { create(:budget, user:, year_month: "2025-08") }.to raise_error(ActiveRecord::ActiveRecordError)
  end
end
