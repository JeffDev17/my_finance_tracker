class Recurring
  def self.generate_recurring_transactions
    transactions = Transaction.where.not(recurring: 'no').where(parent_transaction_id: nil)

    transactions.each do |transaction|
      generate_missing_transactions(transaction)
    end
  end

  def self.generate_missing_transactions(transaction)
    current_date = transaction.expiration
    end_date = Date.current

    while current_date <= end_date
      next_date = calculate_next_expiration(transaction, current_date)

      unless Transaction.exists?(parent_transaction_id: transaction.id, expiration: next_date)
        Transaction.create!(
          description: transaction.description,
          amount: transaction.amount,
          category_id: transaction.category_id,
          expiration: next_date,
          recurring: transaction.recurring,
          account: transaction.account,
          parent_transaction: transaction,
          skip_callbacks: true
        )
      end

      current_date = next_date
    end
  end

  def self.create_recurring_transaction(transaction)
    next_date = calculate_next_expiration(transaction, transaction.expiration)

    return if Transaction.exists?(parent_transaction_id: transaction.id, expiration: next_date)

    if next_date > Date.current
      Transaction.create!(
        description: transaction.description,
        amount: transaction.amount,
        category_id: transaction.category_id,
        expiration: next_date,
        recurring: transaction.recurring,
        account: transaction.account,
        parent_transaction: transaction,
        skip_callbacks: true
      )
    end
  end

  private

  def self.should_generate_next_transaction?(transaction)
    case transaction.recurring
    when "daily"
      transaction.expiration <= Date.current
    when "weekly"
      transaction.expiration <= Date.current + 1.week
    when "monthly"
      transaction.expiration <= Date.current + 1.month
    when "yearly"
      transaction.expiration <= Date.current + 1.year
    else
      false
    end
  end

  def self.calculate_next_expiration(transaction, current_date)
    case transaction.recurring
    when "daily"
      current_date + 1.day
    when "weekly"
      current_date + 1.week
    when "monthly"
      current_date + 1.month
    when "yearly"
      current_date + 1.year
    end
  end
end