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
      @@_BASIC_POST_TYPE_IDS = "5,6,7,8,9"
      @@_ANNOUNCEMENT_POST_TYPE_IDS = "1,2,3,4,10"
      @@_TRAINING_POST_TYPE_IDS = "11,12,13,18"
      @@_QUIZ_POST_TYPE_IDS = "14,15"
      @@_SAFETY_TRAINING_POST_TYPE_IDS = "16"
      @@_SAFETY_QUIZ_POST_TYPE_IDS = "17"
      @@_SCHEDULE_POST_TYPE_IDS = "19,20"

      def fetch_counters
        UserAnalytic.create(:action => 100, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        result ||= Array.new

        channel_ids = Subscription.where(["user_id =#{@user[:id]} AND is_valid"]).pluck(:channel_id)

        result.push("shift_counter" => Post.where("(post_type = 21 OR title = 'Shift Trade') AND is_valid AND created_at > '#{params[:check_date]}'").count)
        result.push("post_counter" => Post.where("post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid AND created_at > '#{params[:check_date]}'").count)
        result.push("schedule_counter" => Post.where("post_type in (#{@@_SCHEDULE_POST_TYPE_IDS}) AND is_valid AND created_at > '#{params[:check_date]}'").count)
        result.push("notification_counter" => Notification.where("recipient_id = #{@user[:id]} AND created_at > '#{params[:check_date]}'").count)
        member_location_ids = UserPrivilege.where(:owner_id => params[:id], :is_approved => true, :is_valid => true).pluck(:location_id)
        result.push("contact_counter" => UserPrivilege.where("location_id in (?) AND created_at > '#{params[:check_date]}'", member_location_ids).count)
        session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
        result.push("message_counter" => ChatMessage.where("session_id in (?) AND created_at > '#{params[:check_date]}'", session_ids).count)

        render json: { "eXpresso" => result }
      end

      def fetch_shifts
        UserAnalytic.create(:action => 101, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
        @subscriptions = Subscription.where(:is_active => true, :user_id => @user[:id]).pluck(:channel_id)
        @shyfts = ScheduleElement.where("start_at >= '#{params[:startDate]}' AND start_at <= '#{params[:endDate]}' AND channel_id IN (#{@subscriptions.join(", ")})").order("start_at ASC").limit(20)
        render json: @shyfts, each_serializer: ShiftStandaloneSerializer
      end

      def fetch_subscriptions
        result = {}
        result["subscriptions"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        UserAnalytic.create(:action => 102, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
        if UserAnalytic.exists?(:action => 102, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 102, :user_id => @user[:id]).last[:created_at]
          @subscriptions = Subscription.where(["user_id =#{@user[:id]} AND updated_at > ?", last_fetch]).order("updated_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        end

        deleted_ids = Post.where("post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        @subscriptions.each do |s|
          last_sync_time = s[:subscription_last_synchronize].present? ? s[:subscription_last_synchronize] : Time.now.utc
          new_subscription = s[:subscription_last_synchronize].present? ? false : true
          s.check_parameters(last_sync_time, new_subscription, fetch_fresh)
        end

        @subscriptions.map do |subscription|
          if @user[:system_user]
            result["subscriptions"].push(SyncSystemSubscriptionSerializer.new(subscription, root: false))
          else
            result["subscriptions"].push(SyncSubscriptionSerializer.new(subscription, root: false))
          end
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      def fetch_schedules
        result = {}
        result["schedules"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        channels = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc").pluck(:channel_id)

        UserAnalytic.create(:action => 103, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
        if UserAnalytic.exists?(:action => 103, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 103, :user_id => @user[:id]).last[:created_at]
          @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{@@_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND updated_at > ?",
            params[:user_id],
            last_fetch
          ).order("posts.updated_at desc").limit(10)
        else
          last_fetch = DateTime.now.iso8601(3)
          @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND is_valid",
            params[:user_id]
          ).order("posts.updated_at desc").limit(10)
        end

        deleted_ids = Post.where("post_type in (#{@@_SCHEDULE_POST_TYPE_IDS}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        @schedules.each do |p|
          p.check_user(params[:user_id])
        end
        @schedules.map do |schedule|
          result["schedules"].push(SyncScheduleSerializer.new(schedule, root: false))
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      def fetch_user
        if User.exists?(:id => params[:id])
          @user = User.find_by_id(params[:id])
        end
      end

    end
  end
end
