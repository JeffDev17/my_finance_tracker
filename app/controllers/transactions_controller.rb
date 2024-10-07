class TransactionsController < ApplicationController
  before_action :get_transaction
  #skip_before_action :set_transaction, only: [:monthly]
  
  def index
    # mostra os transactions do user em order de tempo
    @transactions = current_user.account.transactions.includes(:category).order(created_at: :desc)
  end

  def show
    # Usa o @transaction do before_action
  end

  def new
    # inicia uma nova transacao p usuario atual
  end

  def create
    @transaction = Transaction.create!(transaction_params)
    if @transaction
      redirect_to transactions_path, notice: 'Transactions were successfully created.'
    else
      render :new
    end

  end

  def edit
    # Usa o @transaction do before_action
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

  def monthly
    # Pega as transacoes do user, lista e agrupa por tabela
    @monthly_transactions = current_user.account.transactions.order(created_at: :desc).group_by { |t| t.created_at.beginning_of_month }
  end

  private

  def transaction_params
    # pega os parametros p transaction em tratamento
    params.require(:transaction).permit(:description, :amount, :category_id, :installment, :installment_number, :expiration).merge(account: current_user.account)
  end

  def get_transaction
    @transaction = Transaction.find(params[:id]) rescue Transaction.new
    #busca id da transaction e obviamente se nao existir == criando transaction 
  end

end