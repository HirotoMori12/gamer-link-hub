class TestNotificationJob < ApplicationJob
  queue_as :default

  def perform(message)
    Rails.logger.info "TestNotificationJob実行: #{message}"
    puts "TestNotificationJob実行: #{message}"
  end
end
