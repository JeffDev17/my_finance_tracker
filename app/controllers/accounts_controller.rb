class AccountsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @account = current_user.account
    @balance = @account.balance
    @recent_transactions = @account.transactions.includes(:category).order(created_at: :desc).limit(5)
    
    totals = @account.transactions.joins(:category).group('categories.category_type').sum(:amount)
    @total_income = totals['income']
    @total_expenses = totals['expense']
  end
end