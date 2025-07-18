class User < ApplicationRecord
  has_secure_password
  has_one :budget
  has_many :draws, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :nickname, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true
end
