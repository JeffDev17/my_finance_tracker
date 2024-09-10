# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

# Clear existing categories
Category.destroy_all

# Income categories
income_categories = [
  "Salary",
  "Freelance Income",
  "Investment Income",
  "Gifts Received",
  "Rental Income",
  "Other Income"
]

# Expense categories
expense_categories = [
  "Housing",
  "Utilities",
  "Groceries",
  "Dining Out",
  "Transportation",
  "Healthcare",
  "Insurance",
  "Debt Payments",
  "Savings",
  "Entertainment",
  "Shopping",
  "Personal Care",
  "Education",
  "Gifts Given",
  "Charity/Donations",
  "Travel",
  "Pets",
  "Hobbies",
  "Subscriptions",
  "Taxes",
  "Miscellaneous Expenses"
]

income_categories.each do |category_name|
  Category.create!(name: category_name, category_type: 'income')
end

expense_categories.each do |category_name|
  Category.create!(name: category_name, category_type: 'expense')
end

puts "Seeded #{Category.count} categories"