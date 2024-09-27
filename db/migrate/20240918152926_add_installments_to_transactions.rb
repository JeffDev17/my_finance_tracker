class AddInstallmentsToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :installment, :integer
  end
end
