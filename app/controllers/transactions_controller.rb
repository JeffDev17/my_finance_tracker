class TransactionsController < ApplicationController
  before_action :get_transaction

  def index
    @transactions = current_user.account.transactions.includes(:category).order(created_at: :desc)
  end

  def show
    @transactions = Transaction.find(params[:id])
  end

  def new
  end

  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      #removi a logica daqui pq ela foi toda para o recurring
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
    @monthly_transactions = current_user.account.transactions.all.group_by { |t| (t.expiration || Date.today).beginning_of_month }
  end

  def recurring
    Recurring.generate_recurring_transactions
    @recurring_transactions = current_user.account.transactions.where.not(recurring: 'no').where(parent_transaction_id: nil)
  end

  def export_xml
    transactions = current_user.account.transactions.includes(:category)
    xml_data = TransactionExport.export_to_xml(transactions, current_user)
    send_data xml_data, filename: "transactions_#{Time.current.strftime('%Y%m%d')}.xml", type: 'application/xml'
    #send data envia dados
  end

  def export_excel
    transactions = current_user.account.transactions.includes(:category)
    file_path = TransactionExport.export_to_excel(transactions, current_user)
    send_file file_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', disposition: 'attachment'
    #send file envia o arquivo já salvo
  end

  def import_excel
    file = params[:file]
    if file.present?
      TransactionImport.import_from_excel(file.path, current_user)
      redirect_to transactions_path, notice: 'Importação concluída com sucesso!'
    else
      redirect_to transactions_path, alert: 'Por favor, selecione um arquivo para importar.'
    end
  end

  def stop_recurring
    transaction = Transaction.find(params[:id])
    transaction.stop_recurring_chain

    redirect_to transactions_path, notice: 'Recurring transactions stopped successfully.'
  end
  def destroy_all
    Transaction.delete_all
    redirect_to transactions_path, notice: 'Todas as transações foram deletadas com sucesso.'

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