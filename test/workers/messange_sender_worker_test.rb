require 'test_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

class MessageSenderWorkerTest < ActiveSupport::TestCase
  setup do
    @msg = Message.create(body: "hello, dear tester", sender_id: "11", 
                          location: "watsapp", recipient_id: "12")
  end

  test 'should send message' do
    Sidekiq::Worker.clear_all
    MessageSenderWorker.perform_async(@msg.id)
    assert_equal 1, MessageSenderWorker.jobs.size
  end
end
