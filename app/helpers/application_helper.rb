module ApplicationHelper
  def br_currency(amount)
    number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".", format: "%u %n")
  end
end
