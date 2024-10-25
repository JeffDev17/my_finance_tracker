class AddRecurringToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :recurring, :string
  end
end
