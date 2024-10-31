class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions

  validates :balance, presence: true, numericality: true

  def name
    "Account ##{id}"
  end

end