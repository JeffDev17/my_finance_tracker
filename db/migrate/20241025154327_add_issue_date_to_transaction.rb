class AddIssueDateToTransaction < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :issue_date, :date
  end
end
