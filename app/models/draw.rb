class Draw < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
