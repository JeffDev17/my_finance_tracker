class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :create, :edit, :update]

  def index
    # Shows current user's transactions, ordered by date with categories
    @transactions = current_user.account.transactions.includes(:category).order(created_at: :desc)
  end

  def show
    # Uses the @transaction set by the before_action
  end

  def new
    # Initializes a new transaction for the current user
    @transaction = Transaction.new(account: current_user.account)
  end

  def create
    @transaction = current_user.account.transactions.new(transaction_params)
    if @transaction.save
      redirect_to @transaction, notice: 'Transaction was successfully created.'
    else
      render :new
    end
  end

  def edit
    # Uses the @transaction set by the before_action
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @transaction.destroy
    flash[:success] = "Transaction was successfully deleted."
    redirect_to transactions_path
  end

  private

  def set_transaction
    # Loads the specific transaction for the current user
    @transaction = current_user.account.transactions.find(params[:id])
  end

  def set_categories
    # Loads all categories for the transactions
    @categories = Category.all
  end

  def transaction_params
    # Permits necessary parameters for creating/updating a transaction
    params.require(:transaction).permit(:description, :amount, :category_id)
  end
end