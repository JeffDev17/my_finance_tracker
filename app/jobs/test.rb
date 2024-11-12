class Test < ApplicationJob
  queue_as :default
  def perform
    puts 'filho de markal, markalzera é'
  end
end