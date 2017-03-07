class Api::MessagesController < ApplicationController
  respond_to :json
  skip_before_action :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  def create
    service = PostMessages.run(params[:message])
    if service.valid?
      render :status => 200,
             :json => { notice: t('.success'),
                        result: service.result }
    else
      render :status => 400,
             :json => { notice: t('.fail'),
                        errors: service.errors.full_messages }
    end
  end

end