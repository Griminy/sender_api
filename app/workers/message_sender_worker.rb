class MessageSenderWorker
  include Sidekiq::Worker
  sidekiq_options queue: "messages"

  def perform(message_id)
    begin
      ActiveRecord::Base.connection_pool.with_connection do
        msg = Message.find(message_id)
        msg.update_attributes(sended_at: Time.zone.now)
      end
    rescue ActiveRecord::ConnectionTimeoutError => e
      if (retry_count += 1) <= 5
        retry
      else
        raise
      end
    rescue Exception => e
      puts "********************************worker"
      puts e.inspect
      puts "********************************worker"
    ensure
      ActiveRecord::Base.clear_active_connections!
      ActiveRecord::Base.connection.close
    end
  end
end
