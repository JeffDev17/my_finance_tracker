module ApplicationHelper
  def br_currency(amount)
    number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".", format: "%u %n")
  end

  def installment_description(transaction)
    "#{transaction.description} #{transaction.installment_number} / #{transaction.installment}"
  end

end
