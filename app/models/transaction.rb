class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category

  after_create :update_account_balance
  after_destroy :update_account_balance
  after_update :update_account_balance

  private

  def update_account_balance
    total_income = account.transactions.joins(:category).where(categories: { category_type: 'income' }).sum(:amount)
    total_expenses = account.transactions.joins(:category).where(categories: { category_type: 'expense' }).sum(:amount)
    account.update(balance: total_income - total_expenses)
  end

end
