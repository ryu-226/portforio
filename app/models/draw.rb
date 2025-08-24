class Draw < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :actual_amount, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :on, ->(date) { where(date: date) }
  scope :in_month, ->(date) { where(date: date.all_month) }
end
