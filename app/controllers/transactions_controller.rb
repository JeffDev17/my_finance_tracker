class TransactionsController < ApplicationController
  before_action :set_transaction
  before_action :set_categories, only: [:new, :edit]
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
    @transaction = Transaction.new(account: current_user.account)
  end

  def create
    total_amount = transaction_params[:amount].to_f
    num_installments = transaction_params[:installment].present? ? transaction_params[:installment].to_i : 1
    #if ternario
    installment_amount = total_amount / num_installments
  
    # Cria uma transaction para cada parcela
    num_installments.times do |number|
      installment_number = number + 1 #aqui o number começa em 0
      installment_date = Date.today + installment_number.months 
  
      current_user.account.transactions.create(
        description: "#{transaction_params[:description]} #{installment_number}/#{num_installments}",
        amount: installment_amount,
        category_id: transaction_params[:category_id],
        created_at: installment_date
      )
    end
  
    redirect_to transactions_path, notice: 'Transactions were successfully created.'
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

  def set_transaction
    @transaction = current_user.account.transactions.find(params[:id]) if params[:id].present?

  end

  def set_categories
    @categories = Category.all
  end

  def transaction_params
    # pega os parametros p transaction em tratamento
    params.require(:transaction).permit(:description, :amount, :category_id, :installment)
  end
end