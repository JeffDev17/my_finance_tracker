class AddStatusToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :status, :string, default: 'pending'
  end
end
