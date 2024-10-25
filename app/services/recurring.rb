class Recurring
  def create_recurring_transaction(transaction)
    return if transaction.recurring == "no"

    # cria ate os proximos 3 meses
    end_date = Date.current + 3.months
    current_date = transaction.expiration

    while current_date <= end_date
      next_date = calculate_next_expiration(transaction, current_date)

      #nao cria se a proxima data é a mesma ou menor
      break if next_date <= current_date

      Transaction.create!(
        description: transaction.description,
        amount: transaction.amount,
        category_id: transaction.category_id,
        expiration: next_date,
        recurring: transaction.recurring,
        account: transaction.account,
        parent_transaction: transaction,
        skip_callbacks: true #evita o famoso loop infinito
      )

      current_date = next_date
    end
  end

  private

  def calculate_next_expiration(transaction, current_date)
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