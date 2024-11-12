class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category
  belongs_to :parent_transaction, class_name: 'Transaction', optional: true
  has_many :children, class_name: "Transaction", foreign_key: "parent_transaction_id", dependent: :destroy

  enum recurring: { no: 'no', daily: 'daily', weekly: 'weekly', monthly: 'monthly', yearly: 'yearly' }

  attr_accessor :skip_callbacks

  before_create :prepare_first_installment
  after_create :handle_post_creation
  after_destroy :update_account_balance
  after_update :update_account_balance

  def stop_recurring_chain
      update!(recurring: "no")
      future_children = children.where('expiration > ?', Date.current)
      future_children.destroy_all
  end
  def destroy_recurring_chain
    children.destroy_all
    destroy
  end

  private

  def handle_post_creation
    return if skip_callbacks
    create_subsequent_installments
    update_account_balance
  end

  def update_account_balance
    return if skip_callbacks

    total_income = account.transactions.joins(:category).where(categories: { category_type: 'income' }).sum(:amount)
    total_expenses = account.transactions.joins(:category).where(categories: { category_type: 'expense' }).sum(:amount)
    account.update(balance: total_income - total_expenses)
  end

  def prepare_first_installment
    return if skip_callbacks

    if installment.present? && installment > 1
      self.installment_number = 1
      self.amount = self.amount / self.installment
    else
      self.installment = 1
      self.installment_number = 0
    end
  end

  def create_subsequent_installments
    return if skip_callbacks
    return unless can_create_installments?

    (2..installment).each do |number|
      Transaction.create!(
        account_id: account_id,
        amount: amount,
        installment: installment,
        installment_number: number,
        expiration: (expiration || Date.today) + (number - 1).months,
        category_id: category_id,
        description: description,
        recurring: recurring,
        skip_callbacks: true
      )
    end
  end

  def can_create_installments?
    installment > 1 && installment_number == 1
  end
end