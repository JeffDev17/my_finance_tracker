class TransactionImport
  def self.import_from_excel(file_path, user)
    spreadsheet = Roo::Spreadsheet.open(file_path)

    (2..spreadsheet.last_row).each do |linha|
      transaction_data = {
        description: spreadsheet.cell(linha, 1),
        category: Category.find_or_create_by(name: spreadsheet.cell(linha, 2)),
        amount: (spreadsheet.cell(linha, 3) || 0).to_f,
        installment: spreadsheet.cell(linha, 4),
        recurring: spreadsheet.cell(linha, 5) ,
        account: user.account,
        expiration: spreadsheet.cell(linha, 7) || Date.today,
        issue_date: spreadsheet.cell(linha, 8) || Date.today,
      }

      Transaction.create(transaction_data)
    end
  end
end
