class AddExpirationToTransaction < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :expiration, :date
    add_index :transactions, :expiration #revisar Index : banco de dados
  end
end
