class Api::MessagesController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  def create
    service = PostMessages.run(params[:message])#(permitted_params[:message])
    if service.valid?
      render :status => 200,
             :json => { notice: t('.success'),
                        result: service.result }
    else
      render :status => 400,
             :json => { notice: t('.fail'),
                        errors: service.errors.full_messages.uniq }
    end
  end

  #curl -v -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/api/messages -d "{\"message\":{\"body\":\"hello, Ivan\", \"delay_to\":\"\", \"sender_id\":\"11\", \"recipient_id\":\"12\", \"locations\":[\"watsapp\", \"telegram\"]}}"

end