class PostMessages < ActiveInteraction::Base

  array :locations
  string :body, :sender_id, 
         :recipient_id, :delay_to

  validates :locations, :body, 
            :sender_id, :recipient_id, presence: true

  validates :body, length: {in: 1..500}
  validate :validate_for_repeat, :validate_delay, :validate_locations

  def execute
    Message.connection.transaction do
      begin
        create_message
        if delay_to.present?
          delay_messages
        else
          post_messages
        end
        @messeges
      rescue Exception => e
        errors.add(:base, e)
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def set_delay_time
    eval(delay_to.split(" ").join("."))
  end

  def delay_messages
    @messeges.each do |msg|
      MessageSenderWorker.perform_in(set_delay_time, msg.id)
    end
  end

  def create_message
    @messeges = []
    locations.each do |l|
      msg = Message.new(body: body, recipient_id: recipient_id,
                        sender_id: sender_id, location: l)
      errors.errors.merge!(@msg.errors) unless msg.save
      @messeges << msg
    end
  end

  def post_messages
    @messeges.each do |msg|
      MessageSenderWorker.perform_async(msg.id)
    end
  end

  def validate_delay
    if delay_to.present?
      time = delay_to.split(" ")
      number_valid = time.first =~ /^[1-9]{1,1}+[0-9]{0,5}$/
      
      valid_time = set_valid_time_methods
      word_valid = valid_time.include?(time.last)
      errors.add(:base, 
                 I18n.t('services.post_message.wrong_delay_format')) unless number_valid && word_valid
    end
  end

  def set_valid_time_methods
    methods = ["day", "minute", "week", "mounth"]
    tmp = []
    methods.each do |t|
      tmp << t+"s"
    end
    methods.concat(tmp)
  end

  def validate_for_repeat
    locations.each do |location|
      same_messages = Message.where("location = ? and recipient_id = ? and body = ?", 
                                    location, recipient_id, body)
      last_message_at = same_messages.order('sended_at asc').pluck(:sended_at).compact.last
      
      if last_message_at && last_message_at >= Time.zone.now - 1.minute
        errors.add(:base, I18n.t('services.post_message.repeated_message'))
      end
    end
  end

  def validate_locations
    messengers = ['telegram', 'watsapp', 'viber']
    locations.each do |l|
      errors.add(:base, I18n.t('services.post_message.wrong_location')) unless messengers.include?(l)
    end
  end

end
