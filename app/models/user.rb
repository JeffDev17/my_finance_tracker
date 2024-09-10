class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :account, dependent: :destroy

  after_create :create_account
  
  validates :username, presence: true, uniqueness: true
  
  private

  def create_account
    Account.create(user: self, balance: 0)
  end

end
