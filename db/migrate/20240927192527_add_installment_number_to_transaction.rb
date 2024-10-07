class AddInstallmentNumberToTransaction < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :installment_number, :integer
  end
end
