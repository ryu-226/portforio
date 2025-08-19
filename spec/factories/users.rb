FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    nickname { "テストユーザー" }
    confirmed_at { Time.current }
    trait :unconfirmed do
      confirmed_at { nil }
    end
  end
end
