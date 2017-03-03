require 'test_helper'

class PostMessagesTest < ActiveSupport::TestCase

  setup do
    @success_params = { body: "hello, dear tester", sender_id: "11", 
                        locations: ["watsapp", "telegram", "viber"], recipient_id: "12",
                        delay_to: ""}
    @blank_params =   { body: "", recipient_id: "", sender_id: "",
                        locations: "", delay_to: ""}
    @wrong_params = { body: "some text", sender_id: "12", 
                      locations: ["wrong"], recipient_id: "12",
                      delay_to: "wrong"}
  end

  test 'should send messeges with valid params' do
    service = PostMessages.run(@success_params)
    assert service.valid?
    assert_equal 3, service.result.length
    assert_equal 3, Message.count
    assert_equal @success_params[:body], service.result.first.body
    assert_equal @success_params[:body], service.result[1].body
    assert_equal @success_params[:body], service.result.last.body
  end

  test 'should not create messages with wrong params' do
    service = PostMessages.run(@wrong_params)
    refute service.valid?
    assert_equal 2, service.errors.count
    assert_equal "Wrong delay format(1 minute)", service.errors.full_messages.first
    assert_equal "One of messangers does not exist", service.errors.full_messages.last
  end

  test 'should not create messages with blank params' do
    service = PostMessages.run(@blank_params)
    refute service.valid?
    assert_equal 1, service.errors.count
    assert_equal "Locations is not a valid array", service.errors.full_messages.first
  end

end
