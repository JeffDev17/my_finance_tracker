class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :category
  belongs_to :parent_transaction, class_name: 'Transaction', optional: true
  has_many :children, class_name: "Transaction", foreign_key: "parent_transaction_id", dependent: :destroy
  has_one_attached :receipt

  enum recurring: { no: 'no', daily: 'daily', weekly: 'weekly', monthly: 'monthly', yearly: 'yearly' }
  enum status: { pending: 'pending', completed: 'completed', failed: 'failed', overdue: 'overdue', refunded: 'refunded' }

  attr_accessor :skip_callbacks

  before_create :prepare_first_installment
  before_save :mark_as_overdue, if: -> { expiration.present? && expiration < Date.today && status == 'pending' }
  after_create :handle_post_creation
  after_destroy :update_account_balance
  #before_update :sub_account_balance, if: -> { will_save_change_to_amount? }
  after_update :update_account_balance, if: -> { saved_change_to_amount? }


  # Collon : // Semi-collon ; // comma ,
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

  def mark_as_overdue
    self.status = 'overdue'
  end
  def handle_post_creation
    return if skip_callbacks
    create_subsequent_installments
    update_account_balance
  end

  def update_account_balance
    multiplier = category.category_type == 'expense' ? -1 : 1

    if destroyed? || marked_for_destruction?
      # Handle deletion case
      balance_change = amount * -multiplier  # Reverse the effect
    else
      # Handle creation and update cases
      old_amount = amount_previously_was || 0
      new_amount = amount || 0
      balance_change = (new_amount - old_amount) * multiplier
    end

    new_balance = account.balance + balance_change
    account.update_columns(balance: new_balance)
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