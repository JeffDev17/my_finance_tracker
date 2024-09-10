class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  def index
    @transactions = current_user.account.transactions.includes(:category).order(created_at: :desc)
  end

  def show
  end

  def new
    @transaction = current_user.account.transactions.build
    @categories = Category.all
  end

  def create
    @transaction = current_user.account.transactions.build(transaction_params)

    if @transaction.save
      redirect_to @transaction, notice: 'Transaction was successfully created.'
    else
      @categories = Category.all
      render :new
    end
  end

  def edit
    @categories = Category.all
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      @categories = Category.all
      render :edit
    end
  end

  def destroy
    @transaction.destroy
    redirect_to transactions_url, notice: 'Transaction was successfully destroyed.'
  end

  private

  def set_transaction
    @transaction = current_user.account.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:description, :amount, :category_id)
  end
end