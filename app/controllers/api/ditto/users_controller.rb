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

        if UserAnalytic.exists?(:action => 1000, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 1000, :user_id => @user[:id]).last[:created_at]
        else
          last_fetch = Time.now
        end

        UserAnalytic.create(:action => 1000, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

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
        result = {}
        result["shifts"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        if UserAnalytic.exists?(:action => 1010, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 1010, :user_id => @user[:id]).last[:created_at]
        else
          last_fetch = Time.now
        end

        UserAnalytic.create(:action => 1010, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        constructed_SQL = ""

        if params[:filters][:show_expired] == "true"
          constructed_SQL = constructed_SQL + "start_at > '#{Time.now}' "
          order = "ASC"
        else params[:filters][:show_expired] == "false"
          constructed_SQL = constructed_SQL + "start_at <= '#{Time.now}' "
          order = "DESC"
        end

        if params[:filters][:display_my_shift_only] == "true"
          constructed_SQL = constructed_SQL + "AND (owner_id = #{@user[:id]} OR coverer_id = #{@user[:id]} OR approver_id = #{@user[:id]}) "
        else
        end

        constructed_SQL = constructed_SQL + "AND trade_status in (#{params[:filters][:status_filter_str]}) "

        if params[:filters][:location].present?
          constructed_SQL = constructed_SQL + "AND location_id in (#{params[:filters][:location]}) "
        else
        end

        @subscriptions = Subscription.where(:is_active => true, :user_id => @user[:id]).pluck(:channel_id)
        @shyfts = ScheduleElement.where("#{constructed_SQL} AND channel_id IN (#{@subscriptions.join(", ")})").order("start_at #{order}").limit(20)

        @shyfts.each do |shift|
          shift.check_user(params[:id])
        end
        @shyfts.map do |shift|
          result["shifts"].push(ShiftStandaloneSerializer.new(shift, root: false))
        end

        #render json: @shyfts, each_serializer: ShiftStandaloneSerializer
        render json: { "eXpresso" => result }
      end

      # GET SUBSCRIPTIONS
      def fetch_subscriptions
        result = {}
        result["subscriptions"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        if UserAnalytic.exists?(:action => 1020, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 1020, :user_id => @user[:id]).last[:created_at]
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        end

        deleted_ids = Subscription.where("user_id = #{@user[:id]} AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 1020, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

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

        if UserAnalytic.exists?(:action => 1030, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 1030, :user_id => @user[:id]).last[:created_at]
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

        UserAnalytic.create(:action => 1030, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

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

        if UserAnalytic.exists?(:action => 1040, :user_id => @user[:id])
          last_fetch = UserAnalytic.where(:action => 1040, :user_id => @user[:id]).last[:created_at]
          #@sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, last_fetch]).order("updated_at desc")
          @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
        else
          last_fetch = DateTime.now.iso8601(3)
          @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
        end

        deleted_ids = ChatSession.where("is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

        UserAnalytic.create(:action => 1040, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

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
          if UserAnalytic.exists?(:action => 1050, :user_id => @user[:id])
            last_fetch = UserAnalytic.where(:action => 1050, :user_id => @user[:id]).last[:created_at]
            #@contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_approved AND updated_at > '#{last_fetch}'")
            @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_valid AND is_approved")
          else
            last_fetch = DateTime.now.iso8601(3)
            @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_valid AND is_approved")
          end

          deleted_ids = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

          UserAnalytic.create(:action => 1050, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

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

        UserAnalytic.create(:action => 1060, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @notifications.map do |notification|
          result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
        end

        result["deleted_ids"].push(deleted_ids)

        render json: { "eXpresso" => result }
      end

      # GET NOTIFICATIONS
      def fetch_more_notifications
        result = {}
        result["notifications"] ||= Array.new
        result["deleted_ids"] ||= Array.new

        location_list = UserPrivilege.where("owner_id = #{@user[:id]} AND is_valid = 't' AND is_approved='t' AND location_id IS NOT NULL AND is_invisible = 'f'").pluck(:location_id)

        @notifications = Notification.where("org_id = 1 AND notify_id = #{params[:id]} AND viewed = 'f' AND id < #{params[:last_notification_id]}").includes(:sender, :recipient).order("created_at desc").limit(20)

        UserAnalytic.create(:action => 1061, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @notifications.map do |notification|
          result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
        end

        render json: { "eXpresso" => result }
      end

      def fetch_posts
        if Subscription.exists?(:id => params[:subscription_id], :is_valid => true)
          result = {}
          result["posts"] ||= Array.new
          result["deleted_ids"] ||= Array.new

          @subscription = Subscription.where(:id => params[:subscription_id], :is_valid => true).first

          if UserAnalytic.exists?(:action => 1070, :user_id => @user[:id])
            last_fetch = UserAnalytic.where(:action => 1070, :user_id => @user[:id]).last[:created_at]
            @posts = Post.where("channel_id = #{@subscription[:channel_id]} AND title != 'Shift Trade' AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid").order("created_at DESC").limit(10)
          else
            last_fetch = DateTime.now.iso8601(3)
            @posts = Post.where("channel_id = #{@subscription[:channel_id]} AND title != 'Shift Trade' AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid").order("created_at DESC").limit(10)
          end

          deleted_ids = Post.where("channel_id = #{@subscription[:channel_id]} AND title != 'Shift Trade' AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

          UserAnalytic.create(:action => 1070, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

          @posts.each do |post|
            post.check_user(params[:id])
          end
          @posts.map do |post|
            #SyncFeedSerializer.new(post, scope: scope, root: false)
            result["posts"].push(SyncFeedSerializer.new(post, root: false))
          end

          result["deleted_ids"].push(deleted_ids)

          render json: { "eXpresso" => result }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => I18n.t('warning.fetch.posts') } }
          ErrorLog.create(
            :file => "users_controller.rb",
            :function => "fetch_posts",
            :error => I18n.t('error.fetch.posts') % {:user_id => params[:id], :subscription_id => params[:subscription_id]} )
        end
      end

      def fetch_more_posts
        if Subscription.exists?(:id => params[:subscription_id], :is_valid => true)
          result = {}
          result["posts"] ||= Array.new

          UserAnalytic.create(:action => 1071, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

          @subscription = Subscription.where(:id => params[:subscription_id], :is_valid => true).first

          @posts = Post.where("channel_id = #{@subscription[:channel_id]} AND title != 'Shift Trade' AND z_index < 9999 AND post_type in (#{@@_BASIC_POST_TYPE_IDS + @@_ANNOUNCEMENT_POST_TYPE_IDS}) AND is_valid AND id < #{params[:last_post_id]}").order("created_at DESC").limit(10)

          @posts.each do |post|
            post.check_user(params[:id])
          end
          @posts.map do |post|
            #SyncFeedSerializer.new(post, scope: scope, root: false)
            result["posts"].push(SyncFeedSerializer.new(post, root: false))
          end

          render json: { "eXpresso" => result }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => I18n.t('warning.fetch.messages') } }
          ErrorLog.create(
            :file => "users_controller.rb",
            :function => "fetch_more_messages",
            :error => I18n.t('error.fetch.messages') % {:user_id => params[:id], :session_id => params[:session_id]} )
        end
      end

      def fetch_messages
        if ChatParticipant.exists?(:user_id => params[:id], :session_id => params[:session_id], :is_valid => true)
          result = {}
          result["messages"] ||= Array.new
          result["deleted_ids"] ||= Array.new

          @participant = ChatParticipant.where(:user_id => params[:id], :session_id => params[:session_id], :is_valid => true).first

          if UserAnalytic.exists?(:action => 1080, :user_id => @user[:id])
            last_fetch = UserAnalytic.where(:action => 1080, :user_id => @user[:id]).last[:created_at]
            @messages = ChatMessage.where("session_id = #{@participant[:session_id]} AND is_valid").order("created_at DESC").limit(10)
          else
            last_fetch = DateTime.now.iso8601(3)
            @messages = ChatMessage.where("session_id = #{@participant[:session_id]} AND is_valid").order("created_at DESC").limit(10)
          end

          deleted_ids = ChatMessage.where("session_id = #{@participant[:session_id]} AND is_valid = 'f' AND updated_at > '#{last_fetch}'").pluck(:id)

          UserAnalytic.create(:action => 1080, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

          @participant.update_attribute(:unread_count, 0)

          @messages.map do |message|
            result["messages"].push(ChatMessageSerializer.new(message, root: false))
          end

          #render json: @messages, each_serializer: ChatMessageSerializer
          result["deleted_ids"].push(deleted_ids)

          render json: { "eXpresso" => result }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => I18n.t('warning.fetch.messages') } }
          ErrorLog.create(
            :file => "users_controller.rb",
            :function => "fetch_messages",
            :error => I18n.t('error.fetch.messages') % {:user_id => params[:id], :session_id => params[:session_id]} )
        end
      end

      def fetch_more_messages
        if ChatParticipant.exists?(:user_id => params[:id], :session_id => params[:session_id], :is_valid => true)
          result = {}
          result["messages"] ||= Array.new

          UserAnalytic.create(:action => 1081, :org_id => 1, :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

          @participant = ChatParticipant.where(:user_id => params[:id], :session_id => params[:session_id], :is_valid => true).first

          @messages = ChatMessage.where("session_id = #{@participant[:session_id]} AND is_valid AND id < #{params[:last_message_id]}").order("created_at DESC").limit(10)

          @messages.map do |message|
            result["messages"].push(ChatMessageSerializer.new(message, root: false))
          end

          render json: { "eXpresso" => result }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => I18n.t('warning.fetch.messages') } }
          ErrorLog.create(
            :file => "users_controller.rb",
            :function => "fetch_more_messages",
            :error => I18n.t('error.fetch.messages') % {:user_id => params[:id], :session_id => params[:session_id]} )
        end
      end

      def fetch_user
        if User.exists?(:id => params[:id])
          @user = User.find_by_id(params[:id])
        end
      end

    end
  end
end
