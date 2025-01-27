class TransactionExport
  def self.export_to_xml(transactions, user)
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.transactions(exported_at: Time.current.iso8601, user: user.email) do
        transactions.each do |transaction|
          xml.transaction do
            xml.description transaction.description
            xml.category transaction.category.name
            xml.amount transaction.amount
            xml.installment transaction.installment_number
            xml.recurring transaction.recurring
            xml.expiration_date transaction.expiration&.strftime('%d/%m/%Y')
            xml.issue_date transaction.issue_date&.strftime('%d/%m/%Y')
          end
        end
      end
    end

    builder.to_xml
  end

  def self.export_to_excel(transactions, user)
    package = Axlsx::Package.new do |table|
      table.workbook.add_worksheet(name: "Transactions") do |sheet|
        sheet.add_row ["Description", "Category", "Amount", "Total Installments", "Installment No", "Recurring", "Account", "Expiration Date", "Issue Date", "Status", "User"]

        transactions.each do |transaction|
          sheet.add_row [
                          transaction.description,
                          transaction.category.name,
                          transaction.amount,
                          transaction.installment,
                          transaction.installment_number,
                          transaction.recurring,
                          user.account.name,
                          format_date(transaction.expiration),
                          format_date(transaction.issue_date),
                          transaction.status.humanize,
                          user.email
                        ]
        end
      end
    end

    file_path = Rails.root.join('public', "transactions_#{Time.current.strftime('%Y%m%d')}.xlsx")
    package.serialize(file_path)

    file_path
  end

  private

  def self.format_date(date)
    date&.strftime('%d/%m/%Y')
  end
end