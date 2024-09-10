class AddCategoryTypeToCategories < ActiveRecord::Migration[7.2]
    def change
      add_column :categories, :category_type, :string, default: 'expense'
      add_index :categories, :category_type
    end
  end