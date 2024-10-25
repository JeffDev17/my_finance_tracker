class AddParentTransactionIdToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :parent_transaction_id, :integer
    add_foreign_key :transactions, :transactions, column: :parent_transaction_id, on_delete: :cascade
  end
end
