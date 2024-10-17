class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category

  before_create :prepare_first_installment
  after_create :create_subsequent_installments, :update_account_balance
  after_destroy :update_account_balance
  after_update :update_account_balance

  private

  def update_account_balance
    total_income = account.transactions.joins(:category).where(categories: { category_type: 'income' }).sum(:amount)
    total_expenses = account.transactions.joins(:category).where(categories: { category_type: 'expense' }).sum(:amount)
    account.update(balance: total_income - total_expenses)
  end

  def prepare_first_installment
    unless installment_number.present?
      self.installment_number = 1
      self.amount = self.amount / self.installment
    end
  end



  def create_subsequent_installments
    if can_create_installments?
      (2..installment).each do |number|
        params = {
          account_id: account_id,
          amount: amount,
          installment: installment,
          installment_number: number,
          expiration: expiration + (number - 1).months,
          category_id: category_id,
          description: description
        }
        Transaction.create!(params)
      end
    end
  end

  def can_create_installments?
    installment > 1 && installment_number == 1
  end
end

