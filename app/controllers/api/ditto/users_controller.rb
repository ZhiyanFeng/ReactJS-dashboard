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

      # GET COUNTERS
      def fetch_counters

        if UserAnalytic.exists?(:action => 100, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 100, :user_id => @user[:id]).last[:created_at]
        else
          last_fetch = Time.now
        end

        UserAnalytic.create(:action => 100, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        result ||= Array.new

        channel_ids = Subscription.where(["user_id =#{@user[:id]} AND is_valid"]).pluck(:channel_id)

        result.push("shift_counter" => Post.where("(post_type = 21 OR title = 'Shift Trade') AND is_valid AND created_at > '#{last_fetch}'").count)
        result.push("post_counter" => Post.where("post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid AND created_at > '#{last_fetch}'").count)
        result.push("schedule_counter" => Post.where("post_type in (#{@@_SCHEDULE_POST_TYPE_IDS}) AND is_valid AND created_at > '#{last_fetch}'").count)
        result.push("notification_counter" => Notification.where("recipient_id = #{@user[:id]} AND created_at > '#{last_fetch}'").count)
        member_location_ids = UserPrivilege.where(:owner_id => params[:id], :is_approved => true, :is_valid => true).pluck(:location_id)
        result.push("contact_counter" => UserPrivilege.where("location_id in (?) AND created_at > '#{last_fetch}'", member_location_ids).count)
        session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
        result.push("message_counter" => ChatMessage.where("session_id in (?) AND created_at > '#{last_fetch}'", session_ids).count)

        render json: { "eXpresso" => result }
      end

      # GET SHIFTS
      def fetch_shifts
        UserAnalytic.create(:action => 101, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
        @subscriptions = Subscription.where(:is_active => true, :user_id => @user[:id]).pluck(:channel_id)
        @shyfts = ScheduleElement.where("start_at >= '#{params[:startDate]}' AND start_at <= '#{params[:endDate]}' AND channel_id IN (#{@subscriptions.join(", ")})").order("start_at ASC").limit(20)
        render json: @shyfts, each_serializer: ShiftStandaloneSerializer
      end

      # GET SUBSCRIPTIONS
      def fetch_subscriptions
        result = {}
        result["subscriptions"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        if UserAnalytic.exists?(:action => 102, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 102, :user_id => @user[:id]).last[:created_at]
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        end

        deleted_ids = Subscription.where("user_id = #{@user[:id]} AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 102, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @subscriptions.each do |s|
          last_sync_time = s[:subscription_last_synchronize].present? ? s[:subscription_last_synchronize] : Time.now.utc
          new_subscription = s[:subscription_last_synchronize].present? ? false : true
          s.check_parameters(last_sync_time, new_subscription, last_fetch)
        end

        @subscriptions.map do |subscription|
          if @user[:system_user]
            result["subscriptions"].push(SyncSubscriptionSerializerV2.new(subscription, root: false))
          else
            result["subscriptions"].push(SyncSubscriptionSerializerV2.new(subscription, root: false))
          end
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      # GET SCHEDULES
      def fetch_schedules
        result = {}
        result["schedules"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        channels = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc").pluck(:channel_id)

        if UserAnalytic.exists?(:action => 103, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 103, :user_id => @user[:id]).last[:created_at]
          @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{@@_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND is_valid",
            params[:user_id]
          ).order("posts.updated_at desc").limit(10)
          #@schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{@@_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND updated_at > ?",
          #  params[:user_id],
          #  last_fetch
          #).order("posts.updated_at desc").limit(10)
        else
          last_fetch = DateTime.now.iso8601(3)
          @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{@@_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND is_valid",
            params[:user_id]
          ).order("posts.updated_at desc").limit(10)
        end

        deleted_ids = Post.where("post_type in (#{@@_SCHEDULE_POST_TYPE_IDS}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 103, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @schedules.each do |p|
          p.check_user(params[:user_id])
        end
        @schedules.map do |schedule|
          result["schedules"].push(SyncScheduleSerializer.new(schedule, root: false))
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      # GET SESSIONS
      def fetch_sessions
        result = {}
        result["sessions"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)

        if UserAnalytic.exists?(:action => 104, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 104, :user_id => @user[:id]).last[:created_at]
          #@sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, last_fetch]).order("updated_at desc")
          @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
        end

        deleted_ids = ChatSession.where("is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 104, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @sessions.map do |session|
          result["sessions"].push(SyncChatSerializer.new(session, root: false))
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      # GET CONTACTS
      def fetch_contacts
        result = {}
        result["contacts"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        location_list = UserPrivilege.where("owner_id = #{@user[:id]} AND is_valid = 't' AND is_approved='t' AND location_id IS NOT NULL AND is_invisible = 'f'").pluck(:location_id)

        if location_list.count > 0
          if UserAnalytic.exists?(:action => 105, :user_id => @user[:id])
            last_fetch = UserAnalytic.where(:action => 105, :user_id => @user[:id]).last[:created_at]
            #@contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_approved AND updated_at > '#{last_fetch}'")
            @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_valid AND is_approved")
          else
            last_fetch = DateTime.now.iso8601(3)
            @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_valid AND is_approved")
          end

          deleted_ids = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

          UserAnalytic.create(:action => 105, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

          @contacts.map do |contact|
            result["contacts"].push(SyncContactThruPrivilegeSerializer.new(contact, root: false))
          end

          result["deleted_ids"].push(deleted_ids)
        end

        render json: { "eXpresso" => result }
      end

      # GET NOTIFICATIONS
      def fetch_notifications
        result = {}
        result["notifications"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        location_list = UserPrivilege.where("owner_id = #{@user[:id]} AND is_valid = 't' AND is_approved='t' AND location_id IS NOT NULL AND is_invisible = 'f'").pluck(:location_id)

        if UserAnalytic.exists?(:action => 106, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 106, :user_id => @user[:id]).last[:created_at]
          @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(20)
          #@notifications = Notification.where("org_id = ? AND notify_id = ? AND viewed = 'false' AND updated_at > ?",
          #  @user[:active_org],
          #  params[:id],
          #  last_fetch
          #).includes(:sender, :recipient).order("created_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(20)
        end

        deleted_ids = Notification.where("org_id = #{@user[:active_org]} AND notify_id = #{params[:id]} AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 106, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @notifications.map do |notification|
          result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      def fetch_posts
        result = {}
        result["posts"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        @subscription = Subscription.find(params[:subscription_id])

        if UserAnalytic.exists?(:action => 107, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 107, :user_id => @user[:id]).last[:created_at]
          @posts = Post.where("channel_id = #{@subscription[:channel_id]} AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid")
        else
          last_fetch = DateTime.now.iso8601(3)
          @posts = Post.where("channel_id = #{@subscription[:channel_id]} AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid")
        end

        deleted_ids = Post.where("channel_id = #{@subscription[:channel_id]} AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 107, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @posts.each do |post|
          post.check_user(object.user_id)
        end
        @posts.map do |post|
          SyncFeedSerializer.new(post, scope: scope, root: false)
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
