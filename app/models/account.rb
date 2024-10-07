class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  validates :balance, presence: true, numericality: true
end