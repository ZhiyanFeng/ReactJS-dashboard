include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class UsersController < ApplicationController
      class User < ::User
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end
      
      before_filter :restrict_access, :set_headers, :except => [:validate_user]
      before_filter :validate_session, :except => [:verify, :invite_from_dashboard, :manage_user, :join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password, :logout]
      before_filter :fetch_user, :except => [:verify, :index, :join_org, :set_admin, :reset_password]

      respond_to :json

      def fetch_user
        if User.exists?(:id => params[:id])
          @user = User.find_by_id(params[:id])
        end
      end
      
      def index
        @users = User.all
        render json: @users, each_serializer: UserProfileSerializer
      end

      def show
        render json: @user, serializer: UserProfileSerializer
      end

      def create
        @user = User.new(:first_name => params[:user][:first_name], :last_name =>params[:user][:last_name], :password => params[:user][:password], :email => params[:user][:email], :validated => true)
        if @user.save
          if Invitation.exists?(:email => @user[:email])
            @invitation = Invitation.find_by_email(@user[:email])
            @user.update_attribute(:active_org, @invitation[:org_id])
            @user.update_attribute(:user_group, @invitation[:user_group]) if @invitation[:user_group].present?
            @user.update_attribute(:location, @invitation[:location]) if @invitation[:location].present?
            @user.update_attribute(:phone_number, @invitation[:phone_number]) if @invitation[:phone_number].present?
            is_admin = @invitation[:is_admin] == true ? true : false
            @key = UserPrivilege.new(:org_id => @invitation[:org_id], :owner_id => @user[:id])
            if @key.create_key_for(is_admin)
              
              #render json: @key, serializer: UserPrivilegeSerializer
              @invitation.update_attribute(:is_valid, false);
            else
              @invitation.update_attribute(:is_valid, false);
              
            end
            #NotificationsMailer.user_validation_with_invitation(@user).deliver
          else
            #NotificationsMailer.user_validation(@user).deliver
          end
          #NotificationsMailer.user_validation(@user).deliver
          
          render json: @user, serializer: UserProfileSerializer
        else
          if @user.errors.first.presence
            #message = @user.errors.first.first + "" + @user.errors.first.second
            render json: { "eXpresso" => { "code" => -103, "message" => @user.errors } }
          end
        end
      end
      
      def join_org
        if UserPrivilege.exists?(:org_id => params[:org_id], :owner_id => params[:id])
          @key = UserPrivilege.where(:org_id => params[:org_id], :owner_id => params[:id]).first
          render json: @key, serializer: UserPrivilegeSerializer
        else
          @key = UserPrivilege.new(:org_id => params[:org_id], :owner_id => params[:id])
          if @key.create_key_for(false)
            
            render json: @key, serializer: UserPrivilegeSerializer
          else
            render json: @key.errors
          end
        end
      end
      
      def leave_org
        if @user.leave_org
          render json: { "eXpresso" => { "code" => 1, "message" => "Leave organization successful." } }
        else
          render json: { "eXpresso" => {"code" => -101, "message" => "Leave organization failed." } }
        end
      end
      
      def switch_org
        if @user.update_attribute(:active_org, 0)
          render :json => @user, serializer: UserProfileSerializer
        else
          render :json => @user.errors
        end
      end
      
      def select_org
        if Mession.exists?(:id => params[:id])
          @mession = Mession.find(params[:id])
          if @mession.update_attribute(:org_id, params[:org_id])
            @user.update_attribute(:active_org, params[:org_id])
            render :json => @mession, serializer: MessionSerializer
          else
            render :json => @mession.errors
          end
        end        
      end

      def sync
        @post_type_post_ids = "5,6,7,8,9"
        @post_type_announcement_ids = "1,2,3,4,10"
        @post_type_training_ids = "11,12,13,18"
        @post_type_quiz_ids = "14,15"
        @post_type_safety_training_ids = "16"
        @post_type_safety_quiz_ids = "17"
        @post_type_schedule_ids = "19,20"
        r_size = params[:size].presence ? params[:size] : 15
        if params[:last_updated_date].presence

        else
          @announcements = Post.where("org_id = ? AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
              @user[:active_org], 
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
          @announcements.each do |p|
            p.check_user(params[:user_id])
          end

          @newsfeeds = Post.where("org_id = ? AND post_type IN (#{@post_type_post_ids}) AND is_valid AND created_at <= ?", 
              @user[:active_org], 
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
          @newsfeeds.each do |p|
            p.check_user(params[:user_id])
          end
          
          @trainings = Post.where("org_id = ? AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            Time.now
          ).order("posts.updated_at asc")

          @quizzes = Post.where("org_id = ? AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
            @user[:active_org]
          ).order("posts.updated_at asc")
          @quizzes.each do |p|
            p.check_user(params[:user_id])
          end

          @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(100)

          @contacts = User.where("active_org = ? AND id != ? AND is_valid", @user[:active_org], @user[:id]).order("first_name ASC, last_name ASC")
      
          session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
          @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")

          result = {}
          result["announcements"] ||= Array.new
          result["newsfeeds"] ||= Array.new
          result["trainings"] ||= Array.new
          result["quizzes"] ||= Array.new
          result["notifications"] ||= Array.new
          result["contacts"] ||= Array.new
          result["sessions"] ||= Array.new
          #result["announcements"] = ActiveModel::ArraySerializer.new(@announcements, each_serializer: AnnouncementSerializer)
          @announcements.map do |announcement|
            result["announcements"].push(AnnouncementSerializer.new(announcement, root: false))
          end
          #result["newsfeeds"] = ActiveModel::ArraySerializer.new(@newsfeeds, each_serializer: NewsfeedSerializer)
          @newsfeeds.map do |newsfeed|
            result["newsfeeds"].push(NewsfeedSerializer.new(newsfeed, root: false))
          end
          #result["trainings"] = ActiveModel::ArraySerializer.new(@trainings, each_serializer: NewsfeedSerializer)
          @trainings.map do |training|
            result["trainings"].push(NewsfeedSerializer.new(training, root: false))
          end
          #result["quizzes"] = ActiveModel::ArraySerializer.new(@quizzes, each_serializer: QuizzesSerializer)
          @quizzes.map do |quiz|
            result["quizzes"].push(QuizzesSerializer.new(quiz, root: false))
          end
          #result["notifications"] = ActiveModel::ArraySerializer.new(@notifications, each_serializer: NotificationSerializer)
          @notifications.map do |notification|
            result["notifications"].push(NotificationSerializer.new(notification, root: false))
          end
          #result["contacts"] = ActiveModel::ArraySerializer.new(@contacts, each_serializer: UserProfileSerializer)
          @contacts.map do |contact|
            result["contacts"].push(UserProfileSerializer.new(contact, root: false))
          end
          #result["sessions"] = ActiveModel::ArraySerializer.new(@sessions, each_serializer: ChatSessionSerializer)
          @sessions.map do |session|
            result["sessions"].push(ChatSessionSerializer.new(session, root: false))
          end

          #render json: result.to_json
          render json: { "eXpresso" => result }
        end
      end

      def synchronize
        @post_type_post_ids = "5,6,7,8,9"
        @post_type_announcement_ids = "1,2,3,4,10"
        @post_type_training_ids = "11,12,13,18"
        @post_type_quiz_ids = "14,15"
        @post_type_safety_training_ids = "16"
        @post_type_safety_quiz_ids = "17"
        @post_type_schedule_ids = "19,20"
        #UserAnalytic.create(:action => 4, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
        fetch_size = params[:size].presence ? params[:size] : 15
        fetch_all = params[:options].presence ? false : true
        if params[:last_sync_time].presence
          fetch_time = Time.zone.parse(params[:last_sync_time]).utc
          fetch_fresh = false
        else
          fetch_time = Time.now
          fetch_fresh = true
        end

        if params[:before].present?
          fetch_history = true
        else
          fetch_history = false
        end

        result = {}
        result["server_sync_time"] = DateTime.now.iso8601(3)
        result["organizations"] ||= Array.new
        result["feeds"] ||= Array.new
        result["announcements"] ||= Array.new
        result["newsfeeds"] ||= Array.new
        result["trainings"] ||= Array.new
        result["safety_trainings"] ||= Array.new
        result["quizzes"] ||= Array.new
        result["safety_quizzes"] ||= Array.new
        result["schedules"] ||= Array.new
        result["notifications"] ||= Array.new
        result["contacts"] ||= Array.new
        result["sessions"] ||= Array.new

        @organization = Organization.find(@user[:active_org])
        fetch_location_only = @organization[:secure_network]
        #if true
        if @user[:active_org] == 1
          #####################################
          
          # -- START FETCH ORGANIZTION -- #
          if fetch_all || params[:options][:organizations].presence
            @organizations = Organization.where(:id => @user[:active_org])
            @organizations.map do |organization|
              result["organizations"].push(OrganizationSeekSerializer.new(organization, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ORGANIZTION -- #

          # -- START FETCH FEED -- #
          if fetch_all || params[:options][:feeds].presence
            if fetch_history
              @feeds = Post.where("org_id = 1 AND (location = ? OR location = 0) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND id < ? AND is_valid", 
                @user[:location], 
                params[:before]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            elsif fetch_fresh
              @feeds = Post.where("org_id = 1 AND (location = ? OR location = 0) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND is_valid", 
                @user[:location]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @feeds = Post.where("org_id = 1 AND (location = ? OR location = 0) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND updated_at > ?", 
                @user[:location], 
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @feeds.each do |p|
              p.check_user(params[:user_id])
            end
            @feeds.map do |feed|
              result["feeds"].push(SyncFeedSerializer.new(feed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH FEED -- #

                    # -- START FETCH ANNOUNCEMENT -- #
          if fetch_all || params[:options][:announcements].presence
            if fetch_fresh
              @announcements = Post.where("org_id = 1 AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid"
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc").limit(fetch_size)
            else
              @announcements = Post.where("org_id = 1 AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?",
                fetch_time
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc")
            end

            @announcements.each do |p|
              p.check_user(params[:user_id])
            end

            @announcements.map do |announcement|
              result["announcements"].push(SyncAnnouncementSerializer.new(announcement, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ANNOUNCEMENT -- #

          # -- START FETCH NEWSFEED -- #
          if fetch_all || params[:options][:newsfeeds].presence
            if fetch_fresh
              @newsfeeds = Post.where("org_id = 1 AND (location = ? OR location = 0) AND post_type IN (#{@post_type_post_ids}) AND is_valid", 
                @user[:location]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @newsfeeds = Post.where("org_id = 1 AND (location = ? OR location = 0) AND post_type IN (#{@post_type_post_ids}) AND updated_at > ?", 
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @newsfeeds.each do |p|
              p.check_user(params[:user_id])
            end
            @newsfeeds.map do |newsfeed|
              result["newsfeeds"].push(SyncNewsfeedSerializer.new(newsfeed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NEWSFEED -- #

          # -- START FETCH TRAINING -- #
          if fetch_all || params[:options][:trainings].presence
            if fetch_fresh
              @trainings = Post.where("org_id = 1 AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid"
              ).order("posts.updated_at asc")
            else
              @trainings = Post.where("org_id = 1 AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                fetch_time
              ).order("posts.updated_at asc")
            end
            @trainings.map do |training|
              result["trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH TRAINING -- #

          # -- START FETCH SAFETY TRAINING -- #
          if fetch_all || params[:options][:safety_trainings].presence
            if fetch_fresh
              @strainings = Post.where("org_id = 1 AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid"
              ).order("posts.updated_at asc")
            else
              @strainings = Post.where("org_id = 1 AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                fetch_time
              ).order("posts.updated_at asc")
            end
            @strainings.map do |training|
              result["safety_trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY TRAINING -- #

          # -- START FETCH QUIZ -- #
          if fetch_all || params[:options][:quizzes].presence
            if fetch_fresh
              @quizzes = Post.where("org_id = 1 AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid"
              ).order("posts.updated_at asc")
            else
              @quizzes = Post.where("org_id = 1 AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                fetch_time
              ).order("posts.updated_at asc")
            end
            @quizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @quizzes.map do |quiz|
              result["quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH QUIZ -- #

          # -- START FETCH SAFETY QUIZ -- #
          if fetch_all || params[:options][:safety_quizzes].presence
            if fetch_fresh
              @squizzes = Post.where("org_id = 1 AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid"
              ).order("posts.updated_at asc")
            else
              @squizzes = Post.where("org_id = 1 AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                fetch_time
              ).order("posts.updated_at asc")
            end
            @squizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @squizzes.map do |quiz|
              result["safety_quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY QUIZ -- #

          # -- START FETCH SCHEDULES -- #
          if fetch_all || params[:options][:schedules].presence
            if fetch_fresh
              @schedules = Post.where("org_id = 1 AND (z_index < 9999 OR owner_id = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid",
                params[:user_id]
              ).order("posts.updated_at desc").limit(15)
            else
              @schedules = Post.where("org_id = 1 AND (z_index < 9999 OR owner_id = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?",
                params[:user_id],
                fetch_time
              ).order("posts.updated_at desc").limit(15)
            end
            @schedules.each do |p|
              p.check_user(params[:user_id])
            end
            @schedules.map do |quiz|
              result["schedules"].push(SyncScheduleSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SCHEDULES -- #

          # -- START FETCH NOTIFICATION -- #
          if fetch_all || params[:options][:notifications].presence
            if fetch_fresh
              @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(50)
            else
              @notifications = Notification.where("org_id = ? AND notify_id = ? AND viewed = 'false' AND updated_at > ?",
                @user[:active_org], 
                params[:id],
                fetch_time
              ).includes(:sender, :recipient).order("created_at desc")
            end
            @notifications.map do |notification|
              result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NOTIFICATION -- #

          # -- START FETCH CONTACT INFORMATION -- #
          if fetch_all || params[:options][:contacts].presence
            if fetch_fresh
              @contacts = User.where("active_org = 1 AND location = ? AND id != ? AND is_valid", @user[:location], @user[:id])
            else
              @contacts = User.where("active_org = 1 AND location = ? AND id != ? AND created_at > ?", @user[:location], @user[:id], fetch_time)
            end
            @contacts.map do |contact|
              result["contacts"].push(SyncContactSerializer.new(contact, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CONTACT INFORMATION -- #

          # -- START FETCH CHAT SESSION -- #
          if fetch_all || params[:options][:sessions].presence
            session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
            if fetch_fresh
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
            else
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, fetch_time]).order("updated_at desc")
            end
            @sessions.map do |session|
              result["sessions"].push(SyncChatSerializer.new(session, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CHAT SESSION -- #


          #####################################
        elsif @organization[:secure_network] == false
          #####################################


          # -- START FETCH ORGANIZTION -- #
          if fetch_all || params[:options][:organizations].presence
            @organizations = Organization.where(:id => @user[:active_org])
            @organizations.map do |organization|
              result["organizations"].push(OrganizationSeekSerializer.new(organization, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ORGANIZTION -- #
          # -- START FETCH FEED -- #
          if fetch_all || params[:options][:feeds].presence
            if fetch_history
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND id < ? AND is_valid", 
                @user[:active_org],
                @user[:location],
                params[:before]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            elsif fetch_fresh
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND is_valid", 
                @user[:active_org], 
                @user[:location],
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @feeds.each do |p|
              p.check_user(params[:user_id])
            end
            @feeds.map do |feed|
              result["feeds"].push(SyncFeedSerializer.new(feed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH FEED -- #

          # -- START FETCH ANNOUNCEMENT -- #
          if fetch_all || params[:options][:announcements].presence
            if fetch_fresh
              @announcements = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc").limit(fetch_size)
            else
              @announcements = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc")
            end

            @announcements.each do |p|
              p.check_user(params[:user_id])
            end

            @announcements.map do |announcement|
              result["announcements"].push(SyncAnnouncementSerializer.new(announcement, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ANNOUNCEMENT -- #

          # -- START FETCH NEWSFEED -- #
          if fetch_all || params[:options][:newsfeeds].presence
            if fetch_fresh
              @newsfeeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids}) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @newsfeeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids}) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @newsfeeds.each do |p|
              p.check_user(params[:user_id])
            end
            @newsfeeds.map do |newsfeed|
              result["newsfeeds"].push(SyncNewsfeedSerializer.new(newsfeed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NEWSFEED -- #

          # -- START FETCH TRAINING -- #
          if fetch_all || params[:options][:trainings].presence
            if fetch_fresh
              @trainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @trainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @trainings.map do |training|
              result["trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH TRAINING -- #

          # -- START FETCH SAFETY TRAINING -- #
          if fetch_all || params[:options][:safety_trainings].presence
            if fetch_fresh
              @strainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @strainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @strainings.map do |training|
              result["safety_trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY TRAINING -- #

          # -- START FETCH QUIZ -- #
          if fetch_all || params[:options][:quizzes].presence
            if fetch_fresh
              @quizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @quizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @quizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @quizzes.map do |quiz|
              result["quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH QUIZ -- #

          # -- START FETCH SAFETY QUIZ -- #
          if fetch_all || params[:options][:safety_quizzes].presence
            if fetch_fresh
              @squizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @squizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @squizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @squizzes.map do |quiz|
              result["safety_quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY QUIZ -- #

          # -- START FETCH SCHEDULES -- #
          if fetch_all || params[:options][:schedules].presence
            if fetch_fresh
              @schedules = Post.where("org_id = ? AND (z_index < 9999 OR owner_id = ?) AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                params[:id],
                @user[:location]
              ).order("posts.updated_at desc")
            else
              @schedules = Post.where("org_id = ? AND (z_index < 9999 OR owner_id = ?) AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                params[:id],
                @user[:location],
                fetch_time
              ).order("posts.updated_at desc")
            end
            @schedules.each do |p|
              p.check_user(params[:user_id])
            end
            @schedules.map do |quiz|
              result["schedules"].push(SyncScheduleSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SCHEDULES -- #

          # -- START FETCH NOTIFICATION -- #
          if fetch_all || params[:options][:notifications].presence
            if fetch_fresh
              @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(100)
            else
              @notifications = Notification.where("org_id = ? AND notify_id = ? AND viewed = 'false' AND updated_at > ?",
                @user[:active_org], 
                params[:id],
                fetch_time
              ).includes(:sender, :recipient).order("created_at desc")
            end
            @notifications.map do |notification|
              result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NOTIFICATION -- #

          # -- START FETCH CONTACT INFORMATION -- #
          if fetch_all || params[:options][:contacts].presence
            if fetch_fresh
              @contacts = User.where("active_org = ? AND id != ? AND is_valid", 
                @user[:active_org], 
                #@user[:location], 
                @user[:id]
              )
            else
              @contacts = User.where("active_org = ? AND id != ? AND created_at > ?", 
                @user[:active_org], 
                #@user[:location], 
                @user[:id], 
                fetch_time
              )
            end
            @contacts.map do |contact|
              result["contacts"].push(SyncContactSerializer.new(contact, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CONTACT INFORMATION -- #

          # -- START FETCH CHAT SESSION -- #
          if fetch_all || params[:options][:sessions].presence
            session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
            if fetch_fresh
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
            else
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, fetch_time]).order("updated_at desc")
            end
            @sessions.map do |session|
              result["sessions"].push(SyncChatSerializer.new(session, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CHAT SESSION -- #


          #####################################
        else
          #####################################


          # -- START FETCH ORGANIZTION -- #
          if fetch_all || params[:options][:organizations].presence
            @organizations = Organization.where(:id => @user[:active_org])
            @organizations.map do |organization|
              result["organizations"].push(OrganizationSeekSerializer.new(organization, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ORGANIZTION -- #
          # -- START FETCH FEED -- #
          if fetch_all || params[:options][:feeds].presence
            if fetch_history
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND id < ? AND is_valid", 
                @user[:active_org],
                @user[:location],
                params[:before]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            elsif fetch_fresh
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND is_valid", 
                @user[:active_org], 
                @user[:location],
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @feeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids},#{@post_type_announcement_ids}) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @feeds.each do |p|
              p.check_user(params[:user_id])
            end
            @feeds.map do |feed|
              result["feeds"].push(SyncFeedSerializer.new(feed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH FEED -- #

          # -- START FETCH ANNOUNCEMENT -- #
          if fetch_all || params[:options][:announcements].presence
            if fetch_fresh
              @announcements = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc").limit(fetch_size)
            else
              @announcements = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_announcement_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :organization).order("posts.created_at desc")
            end

            @announcements.each do |p|
              p.check_user(params[:user_id])
            end

            @announcements.map do |announcement|
              result["announcements"].push(SyncAnnouncementSerializer.new(announcement, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH ANNOUNCEMENT -- #

          # -- START FETCH NEWSFEED -- #
          if fetch_all || params[:options][:newsfeeds].presence
            if fetch_fresh
              @newsfeeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids}) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc").limit(fetch_size)
            else
              @newsfeeds = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_post_ids}) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).includes(:comments, :likes, :flags, :owner).order("posts.created_at desc")
            end
            
            @newsfeeds.each do |p|
              p.check_user(params[:user_id])
            end
            @newsfeeds.map do |newsfeed|
              result["newsfeeds"].push(SyncNewsfeedSerializer.new(newsfeed, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NEWSFEED -- #

          # -- START FETCH TRAINING -- #
          if fetch_all || params[:options][:trainings].presence
            if fetch_fresh
              @trainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @trainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org],
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @trainings.map do |training|
              result["trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH TRAINING -- #

          # -- START FETCH SAFETY TRAINING -- #
          if fetch_all || params[:options][:safety_trainings].presence
            if fetch_fresh
              @strainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @strainings = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_training_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @strainings.map do |training|
              result["safety_trainings"].push(SyncTrainingSerializer.new(training, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY TRAINING -- #

          # -- START FETCH QUIZ -- #
          if fetch_all || params[:options][:quizzes].presence
            if fetch_fresh
              @quizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @quizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @quizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @quizzes.map do |quiz|
              result["quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH QUIZ -- #

          # -- START FETCH SAFETY QUIZ -- #
          if fetch_all || params[:options][:safety_quizzes].presence
            if fetch_fresh
              @squizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                @user[:location]
              ).order("posts.updated_at asc")
            else
              @squizzes = Post.where("org_id = ? AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_safety_quiz_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                @user[:location],
                fetch_time
              ).order("posts.updated_at asc")
            end
            @squizzes.each do |p|
              p.check_user(params[:user_id])
            end
            @squizzes.map do |quiz|
              result["safety_quizzes"].push(SyncQuizzesSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SAFETY QUIZ -- #

          # -- START FETCH SCHEDULES -- #
          if fetch_all || params[:options][:schedules].presence
            if fetch_fresh
              @schedules = Post.where("org_id = ? AND (z_index < 9999 OR owner_id = ?) AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
                @user[:active_org],
                params[:id],
                @user[:location]
              ).order("posts.updated_at desc")
            else
              @schedules = Post.where("org_id = ? AND (z_index < 9999 OR owner_id = ?) AND (location = 0 OR location = ?) AND post_type IN (#{@post_type_schedule_ids}) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND updated_at > ?", 
                @user[:active_org], 
                params[:id],
                @user[:location],
                fetch_time
              ).order("posts.updated_at desc")
            end
            @schedules.each do |p|
              p.check_user(params[:user_id])
            end
            @schedules.map do |quiz|
              result["schedules"].push(SyncScheduleSerializer.new(quiz, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH SCHEDULES -- #

          # -- START FETCH NOTIFICATION -- #
          if fetch_all || params[:options][:notifications].presence
            if fetch_fresh
              @notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(100)
            else
              @notifications = Notification.where("org_id = ? AND notify_id = ? AND viewed = 'false' AND updated_at > ?",
                @user[:active_org], 
                params[:id],
                fetch_time
              ).includes(:sender, :recipient).order("created_at desc")
            end
            @notifications.map do |notification|
              result["notifications"].push(SyncNotificationSerializer.new(notification, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH NOTIFICATION -- #

          # -- START FETCH CONTACT INFORMATION -- #
          if fetch_all || params[:options][:contacts].presence
            if fetch_fresh
              @contacts = User.where("active_org = ? AND id != ? AND is_valid", 
                @user[:active_org], 
                #@user[:location], 
                @user[:id]
              )
            else
              @contacts = User.where("active_org = ? AND id != ? AND created_at > ?", 
                @user[:active_org], 
                #@user[:location], 
                @user[:id], 
                fetch_time
              )
            end
            @contacts.map do |contact|
              result["contacts"].push(SyncContactSerializer.new(contact, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CONTACT INFORMATION -- #

          # -- START FETCH CHAT SESSION -- #
          if fetch_all || params[:options][:sessions].presence
            session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
            if fetch_fresh
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
            else
              @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, fetch_time]).order("updated_at desc")
            end
            @sessions.map do |session|
              result["sessions"].push(SyncChatSerializer.new(session, root: false))
            end
          else
            #skip because it is not specified to have this in the result
          end
          # -- END FETCH CHAT SESSION -- #


          #####################################
        end

        render json: { "eXpresso" => result }
      end

      ### ----- START Announcement REQUESTS ----- ###
      def announcements        
	      r_size = params[:size].presence ? params[:size] : 5

        if @user[:active_org] != 1
          if params[:before].presence
            if params[:order] == "reverse"
              posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id < ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
            end
          elsif params[:since].presence
            #created_at = Post.find(params[:since]).created_at.to_s
            if params[:order] == "reverse"
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id > ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id > ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)            
            end
          else
            if params[:order] == "reverse"
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("announcement"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
            end
          end
        else
          if params[:before].presence
            if params[:order] == "reverse"
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id < ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
            end
          elsif params[:since].presence
            #created_at = Post.find(params[:since]).created_at.to_s
            if params[:order] == "reverse"
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id > ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND id > ? AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)            
            end
          else
            if params[:order] == "reverse"
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
            else
              #posts = Post.where("org_id = ? AND post_type IN (?) AND location IN (?, 0) AND user_group IN (?, 0) AND is_valid AND created_at <= ?", 
                posts = Post.where("org_id = ? AND location = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("announcement"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
            end
          end
        end
        
        UserNotificationCounter.reset(params[:id], @user[:active_org], "announcements") unless params[:silent].present?
        
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        
        render :json => posts, each_serializer: AnnouncementSerializer
      end
      ### ----- END Announcement REQUESTS ----- ###
      
      ###
      def safety_trainings
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_training"),
            params[:before],
            Time.now
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_training"),
            params[:since],
            Time.now
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_training"),
            Time.now
          ).order("posts.updated_at asc")
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "safety_trainings") unless params[:silent].present?
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        render :json => posts, each_serializer: NewsfeedSerializer
      end
      ###

      def safety_quizzes
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_quiz"),
            params[:before],
            Time.now
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_quiz"),
            params[:since],
            Time.now
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("safety_quiz"),
            Time.now
          ).order("posts.updated_at asc")
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "safety_quiz") unless params[:silent].present?
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        render :json => posts, each_serializer: QuizzesSerializer
      end

      ### ----- START Newsfeed REQUESTS ----- ###
      def newsfeeds
        r_size = params[:size].presence ? params[:size] : 5
        if @user[:active_org] != 1
          if params[:before].presence
            if params[:order] == "reverse"
              posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
            else
              posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          elsif params[:since].presence
            #created_at = Post.find(params[:since]).created_at.to_s
            if params[:order] == "reverse"
              posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
            else
              posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          else
            if params[:order] == "reverse"
              posts = Post.where("org_id = ? AND post_type IN (?) AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)            
            else
              posts = Post.where("org_id = ? AND post_type IN (?) AND is_valid AND created_at <= ?", 
                @user[:active_org], 
                PostType.reference_by_base_type("post"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          end
        else
          if params[:before].presence
            if params[:order] == "reverse"
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
            else
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND id < ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                params[:before],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          elsif params[:since].presence
            #created_at = Post.find(params[:since]).created_at.to_s
            if params[:order] == "reverse"
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
            else
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND id > ? AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                params[:since],
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          else
            if params[:order] == "reverse"
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)            
            else
              posts = Post.where("org_id = 1 AND location = ? AND post_type IN (?) AND is_valid AND created_at <= ?", 
                @user[:location], 
                PostType.reference_by_base_type("post"),
                Time.now()
              ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
            end
          end
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "newsfeeds") unless params[:silent].present?
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        
        render :json => posts, each_serializer: NewsfeedSerializer
      end
      
      ### ----- END Newsfeed REQUESTS ----- ###
      
      ### ----- START Event REQUESTS ----- ###
      
      def events
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND id < ? AND is_valid", 
            @user[:active_org], 
            params[:before]
          ).order("posts.created_at desc").limit(15)
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND id > ? AND is_valid", 
            @user[:active_org],
            params[:since]
          ).order("posts.created_at desc").limit(15)
        else
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND is_valid", 
            @user[:active_org]
          ).order("posts.created_at desc").limit(15)
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "events")
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        
        render :json => posts, each_serializer: AnnouncementSerializer
      end
      
      ### ----- END Event REQUESTS ----- ###
      
      ### ----- START Training REQUESTS ----- ###
      
      def trainings
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("training"),
            params[:before],
            Time.now
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("training"),
            params[:since],
            Time.now
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid AND created_at <= ?", 
            @user[:active_org], 
            PostType.reference_by_base_type("training"),
            Time.now
          ).order("posts.updated_at asc")
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "trainings") unless params[:silent].present?
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        
        render :json => posts, each_serializer: NewsfeedSerializer
      end
      
      ### ----- END Training REQUESTS ----- ###
      
      ### ----- START Training REQUESTS ----- ###
      
      def quizzes
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id < ? AND is_valid", 
            @user[:active_org], 
            PostType.reference_by_base_type("quiz"),
            params[:before]
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND id > ? AND is_valid", 
            @user[:active_org], 
            PostType.reference_by_base_type("quiz"),
            params[:since]
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND ((location = #{@user[:location].to_i} AND user_group = #{@user[:user_group].to_i}) OR (location = #{@user[:location].to_i} AND user_group = 0) OR (user_group = #{@user[:user_group].to_i} AND location = 0) OR (location = 0 AND user_group = 0)) AND is_valid", 
            @user[:active_org], 
            PostType.reference_by_base_type("quiz"),
          ).order("posts.updated_at asc")
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "quizzes") unless params[:silent].present?
        posts.each do |p|
          p.check_user(params[:user_id])
        end
        
        render :json => posts, each_serializer: QuizzesSerializer
      end
      
      ### ----- END Training REQUESTS ----- ###
      
      def notifications
        notifications = Notification.where(:org_id => @user[:active_org], :notify_id => params[:id], :viewed => false).includes(:sender, :recipient).order("created_at desc").limit(100)
        
        render :json => notifications, each_serializer: NotificationSerializer
      end
      
      def counters
        counter = UserNotificationCounter.fetch(@user[:id], @user[:active_org])
        render :json => counter, serializer: NotificationCounterSerializer        
      end
      
      def profile
        render json: @user, serializer: UserProfileSerializer
      end
      
      def gallery
        @gallery = Image.where(
          :owner_id => params[:id],
          :image_type => [2,4,5]
        ).order('created_at desc')
        
        @gallery.each do |p|
          p.check_user(params[:user_id])
        end
        
        render json: @gallery, each_serializer: ImageSerializer
      end
      
      def validate_user
        @user = User.find_by_validation_hash(params[:hash])
                
        respond_to do |format|
          if @user.update_attribute(:validated, true)
            
            format.html { redirect_to validated_path }
            format.json { render json: @user }
          else
            format.html { render json: ["Cannot validate user"], status: :unprocessable_entity }
            format.json { render json: ["Cannot validate user"], status: :unprocessable_entity }
          end
        end
      end
      
      def resend_validation_email
        @user = User.find_by_email(params[:email])
        if NotificationsMailer.user_validation(@user).deliver
          render json: { "eXpresso" => { "code" => 1, "message" => "Email resent." } }
        else
          render json: { "eXpresso" => { "code" => -129, "message" => "Email resent failed." } }
        end
      end
      
      def update
        @user.update_attribute(:status, params[:status]) if params[:status].presence
        begin
          @user.update_attribute(:location, params[:location]) if params[:location].presence
        rescue
          @user.update_attribute(:location, 0) if params[:location].presence
        end
        begin
          @user.update_attribute(:user_group, params[:position]) if params[:position].presence
        rescue
          @user.update_attribute(:user_group, 0) if params[:position].presence
        end
        #@user.update_attribute(:status, params[:status]) if params[:status].presence

        @user.update_attribute(:profile_id, params[:profile_id]) if params[:profile_id].presence
        @user.update_attribute(:push_count, @user.push_count - params[:push_count]) if params[:push_count].presence
        
        if params[:org_id].presence
          organization = Organization.find(@user[:active_org])
          type = @user[:profile_id].blank? ? 5 : 6
          @post = Post.new(
            :org_id => params[:org_id],
            :owner_id => @user[:id],
            :title => "New Member!",
            :content => "Hello, I am the newest member of " + organization[:name] + ".", 
            :post_type => type
          )
          if type == 6
            @post.hello_with_image(@user[:profile_id])
          else
            @post.basic_hello
          end
          Follower.follow(4, @post[:id], @user[:id])
          message = @user[:first_name] + " " + @user[:last_name] + " joined your organization!" 
          User.notification_broadcast(@user[:id], @post[:org_id], "post", "join", message, 4, @post[:id])
          #Mession.broadcast(@post[:org_id], "open_app", "join", 4, @post[:id], @user[:id], @user[:id])
        end
        
        render :json => @user, serializer: UserProfileSerializer
      end

      #def destroy
      #  @user = User.find(params[:id])
      #  if @user.update(:is_valid => false)
      #    render :json => @user, serializer: UserProfileSerializer
      #  else
      #    render :json => @user.errors
      #  end
      #end
      
      def contact_list
        #@users = User.where("active_org = ? AND id != ?", params[:active_org], params[:user_id]).order("last_name ASC, first_name ASC")
        #@users = User.where("active_org = ? AND id != ?", @user[:active_org], @user[:id]).order("last_name ASC, first_name ASC")
        #@users = User.where("active_org = ? AND id != ?", @user[:active_org], @user[:id]).order("first_name ASC")
        @users = User.where("active_org = ? AND id != ? AND is_valid", @user[:active_org], @user[:id]).order("first_name ASC, last_name ASC")
        #@users.each do |p|
        #  if p.profile_image.presence
        #    p.profile_image.check_user(params[:user_id])
        #  end
        #end
        render json: @users, each_serializer: UserProfileSerializer
      end
          
      def chat_list
        session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
        @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")
        #@sessions.each do |p|
        #  p.participants.each do |q|
        #    if q.owner.profile_image.presence
        #      q.owner.profile_image.indicate(params[:id])
        #    end
        #  end
        #end
        
        render json: @sessions, each_serializer: ChatSessionSerializer
      end
      
      def reset_password
        if params[:email].present?
          user = User.find_by_email(params[:email])
        elsif params[:phone_number].present?
          user = User.find_by_phone_number(params[:phone_number])
        else
          user = false
        end
          
        if user && user.send_password_reset
          #UserAnalytic.create(:action => 10, :org_id => user[:active_org], :user_id => user[:id], :ip_address => request.remote_ip.to_s)
          render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully reset" } }
        else
          render json: { "eXpresso" => { "code" => -108, "message" => user.errors } }
        end
      end
      
      def change_password
        if User.exists?(:email => params[:email], :is_valid => true)
          @user = User.find_by_email_and_is_valid(params[:email], true)
          #UserAnalytic.create(:action => 10, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
          status = @user.authenticate(params[:password])
          if status == 200
            @user.change_password(params[:new_password])
            render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully changed" } }
          else
            render json: { "eXpresso" => { "code" => -109, "message" => @user.errors } }
          end
        end
      end
      
      def set_admin
        @user = User.find_by_email(params[:email])
        @key = UserPrivilege.where(:org_id => params[:org_id], :owner_id => @user[:id]).first
        if @key.update_attribute(:is_admin, true)
          render json: @key, serializer: UserPrivilegeSerializer
        else
          render json: @key.errors
        end
      end
      
      def remove_admin
        @user = User.find_by_email(params[:email])
        @key = UserPrivilege.where(:org_id => params[:org_id], :owner_id => @user[:id]).first
        if @key.update_attribute(:is_admin, false)
          render json: @key, serializer: UserPrivilegeSerializer
        else
          render json: @key.errors
        end
      end

      def zhu_xiao_zhang_hao
        @user = User.find(params[:id])
        if @user.revoke_account
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => @user.errors } }
        end
      end
      
      def logout
        @mession = Mession.where(:user_id => params[:id], :is_active => true).last
        if @mession.update_attribute(:is_active, false)
          render :json => { "response" => "Success." }
        else
          render :json => @mession.errors
        end
      end
      
      def update_badge_count
        if @user.update_attribute(:push_count, params[:counter])
          render json: { "eXpresso" => { "code" => 1, "message" => "Counter updated successfully" } }
        else
          render json: { "eXpresso" => { "code" => -110, "message" => @user.errors } }
        end
      end
      
      def invite_from_contact
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'
        
        @client = Twilio::REST::Client.new t_sid, t_token
        
        if Rails.env.production?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.staging?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.testing?
          @host = "http://goo.gl/isddrw"
        else
          @host = "http://goo.gl/isddrw"
        end
        
        if @user[:active_org] != 1
          @organization = Organization.where(:id => @user[:active_org]).first
          network_name = @organization[:name]
        else
          @location = Location.where(:id => @user[:location]).first
          network_name = @location[:location_name]
        end

        message = @client.account.messages.create(
          #:body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they’re using to trade shifts and message coworkers. It’s called Coffee Mobile, download here: #{@host}",
          :body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they are using to trade shifts and message coworkers at #{network_name}. Join their network or start your own! #{@host}",
          :to => params[:phone],
          :from => "+16473602178"
        )
        if message 
          ViralityAnalytic.create()
          render json: { "eXpresso" => { "code" => 1, "message" => "Invitation sent" } }
        else
          render json: { "eXpresso" => { "code" => -111, "message" => message.errors } }
        end
      end
      
      def share
        @post = Post.new(
          :org_id => @user[:active_org],
          :owner_id => @user[:id],
          :title => params[:title],
          :content => params[:content],
          :post_type => PostType.reference_by_description(params[:reference])
        )
       
        image = params[:file].presence ? params[:file] : nil
        video = params[:video].presence ? params[:video] : nil
        event = params[:event].presence ? params[:event] : nil
        poll = params[:poll].presence ? params[:poll] : nil
        if @post.save
          @post.update_attribute(:is_valid, false) if image != nil
          render json: @post, serializer: PostSerializer
          @post.compose(image, video, event, poll)
        else
          render json: @post.errors
        end
      end

      private

      def generate_invite_code
        999 + Random.rand(9999-9000)
      end
      
    end
  end
end
