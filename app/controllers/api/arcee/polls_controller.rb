include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
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
        if params[:org_override].present?
          poll.set_org(params[:org_override])
        end

        if params[:dashboard].present?
          if params[:dashboard] == "user_detail_view"
            render json: poll, serializer: DashboardPollUserDetailSerializer
          elsif params[:dashboard] == "quiz_detail_view"
            render json: poll, serializer: DashboardPollQuizDetailSerializer
          end
          #render json: poll, serializer: DashboardQuizDetailSerializer
        else
          #UserAnalytic.create(:action => 6,:org_id => poll[:org_id], :user_id => params[:user_id], :ip_address => request.remote_ip.to_s)
          render json: poll, serializer: QuizDetailSerializer
        end
      end

      def create
        #Rails.logger.debug("person")
        
        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end
      
      def answer
        if params[:questions].present?
          answer_json = params[:questions].to_json.to_s
        elsif params[:answer_json].present?
          answer_json = params[:questions]
          #Rails.logger.debug(answer_json)
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
        if @result.save!
          begin
            @poll = Poll.find(params[:id])
            #UserAnalytic.create(:action => 5,:org_id => @poll[:org_id], :user_id => params[:user_id], :ip_address => request.remote_ip.to_s)
            @poll.update_attribute(:attempts_count, @poll[:attempts_count] + 1)
            if params[:score].to_i >= @poll[:pass_mark].to_i
              @poll.update_attribute(:complete_count, @poll[:complete_count] + 1)
            end
          rescue => error
            #Rails.logger.debug(error)
          ensure
          end
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          #Rails.logger.debug(@result.errors.inspect)
          render json: { "eXpresso" => {"code" => -801, "message" => "Poll results did not upload." } }
        end
      end

      def remind
        poll = Poll.find(params[:id])

        if poll.user_group > 0 && poll.location > 0
          @user_ids = User.where(:active_org => poll.org_id, :user_group => poll.user_group, :location => poll.location).pluck(:id)
        elsif poll.user_group == 0 && poll.location > 0
          @user_ids = User.where(:active_org => poll.org_id, :location => poll.location).pluck(:id)
        elsif poll.user_group > 0 && poll.location == 0
          @user_ids = User.where(:active_org => poll.org_id, :user_group => poll.user_group).pluck(:id)
        else
          @user_ids = User.where(:active_org => poll.org_id).pluck(:id)
        end
        @done = PollResult.where(:poll_id => params[:id]).pluck(:user_id)

        @users = User.where("id IN (?) AND id NOT IN (?)", @user_ids, @done)
        @users.each do |u|
          if @counter = UserNotificationCounter.where(:user_id => u[:id], :org_id => org_id).last
            @notification = Notification.new(
              :source => 4,
              :source_id => source_id,
              :notify_id => u[:id],
              :sender_id => sender_id,
              :recipient_id => sender_id,
              :org_id => org_id,
              :event => event,
              :message => message
            )
            @notification.save
          end
        end
      end

      def update
        if Poll.exists?(params[:id])
          @poll = Poll.find(params[:id])
          if @poll.update_poll(params[:poll])
            render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
          else
            render json: { "eXpresso" => {"code" => -803, "message" => "Could not update the poll." } }
          end          
        else
          render json: { "eXpresso" => {"code" => -802, "message" => "Could not find poll with id=#{params[:id]}." } }
        end
      end

      def destroy
        
      end      
    end
  end
end