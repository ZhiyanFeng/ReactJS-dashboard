include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class PollsController < ApplicationController
      class Poll < ::Poll
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
      
      before_filter :restrict_access, :except => [:create]
      before_filter :set_headers
      
      respond_to :json
      
      def detail
        poll = Poll.find(params[:id])
        #Notification.did_view(params[:user_id], 4, params[:id])
        #UserAnalytic.create(:action => 6,:org_id => poll[:org_id], :user_id => params[:user_id], :ip_address => request.remote_ip.to_s)
        render json: poll, serializer: QuizDetailSerializer
      end
      
      def answer
        if params[:questions].present?
          answer_json = params[:questions].to_json.to_s
        elsif params[:answer_json].present?
          answer_json = params[:questions].as_json.to_s
          Rails.logger.debug(answer_json)
        end
          
        @result = PollResult.new(
          :poll_id => params[:id],
          :user_id => params[:user_id],
          :question_count => params[:question_count],
          :score => params[:score],
          :answer_key => params[:answer_key],
          :answer_json => answer_json,
          :passed => params[:passed]
        )
        if @result.save
          begin
            @poll = Poll.find(params[:id])
            #UserAnalytic.create(:action => 5,:org_id => @poll[:org_id], :user_id => params[:user_id], :ip_address => request.remote_ip.to_s)
            @poll.update_attribute(:attempts_count, @poll[:attempts_count] + 1)
            if params[:question_count].to_i == @poll[:question_count].to_i
              @poll.update_attribute(:complete_count, @poll[:complete_count] + 1)
            end
          rescue
          ensure
          end
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => {"code" => -801, "message" => "Poll results did not upload." } }
        end
      end

      def destroy
        
      end      
    end
  end
end