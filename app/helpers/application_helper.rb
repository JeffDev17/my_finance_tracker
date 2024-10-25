module ApplicationHelper
  def br_currency(amount)
    number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".", format: "%u %n")
  end

  def installment_description(transaction)
    if transaction.installment_number != 0
    "#{transaction.description} #{transaction.installment_number} / #{transaction.installment}"
    else
      "#{transaction.description}"
    end

  end

end
