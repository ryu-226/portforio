FactoryBot.define do
  factory :draw do
    association :user
    date { Date.current }
    amount { 800 }
    actual_amount { nil }
  end
end
