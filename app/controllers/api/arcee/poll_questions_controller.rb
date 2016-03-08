include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class PollQuestionsController < ApplicationController
      class PollQuestion < ::PollQuestion
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
      
      before_filter :fetch_poll_question
      
      respond_to :json

      def fetch_poll_question
        if PollQuestion.exists?(:id => params[:id])
          @poll_question = PollQuestion.find_by_id(params[:id])
        end
      end
      
      def update
        @poll_question.update_attribute(:content, params[:value])

        render json: { "code" => 1, "message" => "Success" }
      end 
    end
  end
end