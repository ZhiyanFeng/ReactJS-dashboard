include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Ditto
    class UsersController < ApplicationController
      class User < ::User
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:validate_user]
      before_filter :validate_session, :except => []
      before_filter :fetch_user, :except => []

      respond_to :json

      def fetch_new
        UserAnalytic.create(:action => 4, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        _BASIC_POST_TYPE_IDS = "5,6,7,8,9"
        _ANNOUNCEMENT_POST_TYPE_IDS = "1,2,3,4,10"
        _TRAINING_POST_TYPE_IDS = "11,12,13,18"
        _QUIZ_POST_TYPE_IDS = "14,15"
        _SAFETY_TRAINING_POST_TYPE_IDS = "16"
        _SAFETY_QUIZ_POST_TYPE_IDS = "17"
        _SCHEDULE_POST_TYPE_IDS = "19,20"

        result = {}
        result["server_sync_time"] = Time.now.utc
        result["subscriptions"] ||= Array.new
        result["posts"] ||= Array.new
        result["shifts"] ||= Array.new
        result["schedules"] ||= Array.new
        result["contacts"] ||= Array.new
        result["notifications"] ||= Array.new
        result["sessions"] ||= Array.new

        channel_ids = Subscription.where(["user_id =#{@user[:id]} AND is_valid"]).pluck(:channel_id)

        shift_count = Posts.where("post_type in ()").count
      end

      def fetch_shifts
        UserAnalytic.create(:action => 100, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @subscriptions = Subscription.where(:is_active => true, :user_id => @user[:id]).pluck(:channel_id)
        @shyfts = ScheduleElement.where("start_at >= '#{params[:startDate]}' AND start_at <= '#{params[:endDate]}' AND channel_id IN (#{@subscriptions.join(", ")})").order("start_at ASC").limit(20)

        render json: @shyfts, each_serializer: ShiftStandaloneSerializer
      end

      def fetch_user
        if User.exists?(:id => params[:id])
          @user = User.find_by_id(params[:id])
        end
      end

    end
  end
end
