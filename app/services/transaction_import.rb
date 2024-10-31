class TransactionImport
  def self.import_from_excel(file_path, user)
    spreadsheet = Roo::Spreadsheet.open(file_path)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row_data = spreadsheet.row(i)
      row = Hash[header.zip(row_data)]

      category = Category.find_or_create_by(name: row.fetch("Category", "não informado"))

      transaction_data = {
        description: row.fetch("Description", "Importado pelo Usuario"),
        category: category,
        amount: row.fetch("Amount", 0).to_f,
        installment: row.fetch("Installment", "não informado"),
        recurring: row.fetch("Recurring", "não informado"),
        account: user.account,
        expiration: parse_date(row.fetch("Expiration Date", "não informado")),
        issue_date: parse_date(row.fetch("Issue Date", "não informado")),
        parent_transaction: row.fetch("Parent Transaction", nil)
      }

      Transaction.create(transaction_data)
    rescue StandardError => e
      Rails.logger.error "Error processing row #{i}: #{e.message}"
    end
  end

  private

  def self.parse_date(date_string)
    Date.strptime(date_string, '%d/%m/%Y') if date_string.present?
  rescue StandardError
    nil
  end
end