# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

env :PATH, ENV['PATH'] #precisa dessa config para ambiente de desenvolvimento p carregar as variaveis
set :output, "/Users/jeffdev/Documents/projects/my_finance_tracker/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

# Roda diariamente para verificar e criar transações recorrentes conforme necessário
every 1.minute do
  runner "Test.perform_later"
  runner "Recurring.generate_recurring_transactions"
end



