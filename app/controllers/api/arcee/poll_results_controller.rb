include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class PollResultsController < ApplicationController
      class PollResult < ::PollResult
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
      
      before_filter :restrict_access
      before_filter :set_headers
      
      respond_to :json
      
      def show
        result = PollResult.find(params[:id])
        #Notification.did_view(params[:user_id], 4, params[:id])

        render json: result
      end 
    end
  end
end