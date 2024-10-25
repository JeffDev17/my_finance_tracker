class TransactionsController < ApplicationController
  before_action :get_transaction

  def index
    @transactions = current_user.account.transactions.includes(:category).order(created_at: :desc)
  end

  def show
  end

  def new
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      #cria recorrente só se nao for uma child
      unless @transaction.parent_transaction_id.present?
        recurring = Recurring.new
        recurring.create_recurring_transaction(@transaction)
      end

      redirect_to transactions_path, notice: 'Transaction was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to @transaction, notice: 'Transaction was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @transaction.recurring != 'no'
      @transaction.destroy_recurring_chain
      flash[:success] = "Recurring transaction and its future transactions were successfully deleted."
    else
      @transaction.destroy
      flash[:success] = "Transaction was successfully deleted."
    end
    redirect_to transactions_path
  end

  def monthly
    @monthly_transactions = current_user.account.transactions.all.group_by { |t| t.expiration.beginning_of_month }
  end

  def recurring
    @recurring_transactions = current_user.account.transactions.where.not(recurring: 'no').where(parent_transaction_id: nil)
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :description,
      :amount,
      :category_id,
      :installment,
      :installment_number,
      :recurring,
      :expiration,
      :issue_date
    ).merge(account: current_user.account)
  end

  def get_transaction
    @transaction = Transaction.find_by(id: params[:id]) || Transaction.new
  end
end