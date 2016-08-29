include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class UsersController < ApplicationController
      class User < ::User
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:validate_user]
      before_filter :validate_session, :except => [:invite_from_dashboard, :mass_invite_from_dashboard, :make_admin, :manage_group_user, :manage_user, :join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password, :revolk_users, :logout]
      before_filter :fetch_user, :except => [:index, :join_org, :set_admin, :mass_invite_from_dashboard, :reset_password, :invite_from_dashboard, :make_admin, :revolk_users]

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
        @user = User.new(params[:user])
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
            else
              APILogger.info "[users.create] auto create key FAILED #{params[:id]} joined #{params[:org_id]}."
            end
            NotificationsMailer.user_validation_with_invitation(@user).deliver
          else
            NotificationsMailer.user_validation(@user).deliver
          end
          #NotificationsMailer.user_validation(@user).deliver

          render json: @user, serializer: UserProfileSerializer
        else
          if @user.errors.first.presence
            #message = @user.errors.first.first + "" + @user.errors.first.second
            render json: { "eXpresso" => { "code" => -100, "message" => @user.errors } }
          end
        end
      end

      def join_org
        @key = UserPrivilege.new(:org_id => params[:org_id], :owner_id => params[:id])
        if @key.create_key_for(false)
          APILogger.info "[users.join_org] #{params[:id]} joined #{params[:org_id]}."
          render json: @key, serializer: UserPrivilegeSerializer
        else
          render json: @key.errors
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
      ### ----- START Announcement REQUESTS ----- ###
      def announcements
	      r_size = params[:size].presence ? params[:size] : 5

        if params[:before].presence
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              params[:before],
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              params[:before],
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
          end
        elsif params[:since].presence
          #created_at = Post.find(params[:since]).created_at.to_s
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              params[:since],
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              params[:since],
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
          end
        else
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("announcement"),
              @user[:location],
              @user[:user_group],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :organization).order("posts.created_at desc").limit(r_size)
          end
        end

        UserNotificationCounter.reset(params[:id], @user[:active_org], "announcements")

        posts.each do |p|
          p.check_user(params[:user_id])
        end
        render :json => posts, each_serializer: AnnouncementSerializer
      end
      ### ----- END Announcement REQUESTS ----- ###

      ### ----- START Newsfeed REQUESTS ----- ###
      def newsfeeds
        r_size = params[:size].presence ? params[:size] : 5

        if params[:before].presence
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              params[:before],
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              params[:before],
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
          end
        elsif params[:since].presence
          #created_at = Post.find(params[:since]).created_at.to_s
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              params[:since],
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              params[:since],
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
          end
        else
          if params[:order] == "reverse"
            posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at asc").last(r_size)
          else
            posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND is_valid AND created_at <= ?",
              @user[:active_org],
              PostType.reference_by_base_type("post"),
              @user[:location],
              Time.now()
            ).includes(:settings, :comments, :likes, :flags, :owner).order("posts.created_at desc").limit(r_size)
          end
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "newsfeeds")
        posts.each do |p|
          p.check_user(params[:user_id])
        end

        render :json => posts, each_serializer: NewsfeedSerializer
      end

      ### ----- END Newsfeed REQUESTS ----- ###

      ### ----- START Event REQUESTS ----- ###

      def events
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND id < ? AND location = ? AND is_valid",
            @user[:active_org],
            params[:before],
            @user[:location]
          ).order("posts.created_at desc").limit(15)
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND id > ? AND location = ? AND is_valid",
            @user[:active_org],
            params[:since],
            @user[:location]
          ).order("posts.created_at desc").limit(15)
        else
          posts = Post.where("org_id = ? AND post_type IN (9,10,14,15,16) AND location = ? AND is_valid",
            @user[:active_org],
            @user[:location]
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
          posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("training"),
            params[:before],
            @user[:location],
            @user[:user_group],
            Time.now
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("training"),
            params[:since],
            @user[:location],
            @user[:user_group],
            Time.now
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("training"),
            @user[:location],
            @user[:user_group],
            Time.now
          ).order("posts.updated_at asc")
        end
        UserNotificationCounter.reset(params[:id], @user[:active_org], "trainings")
        posts.each do |p|
          p.check_user(params[:user_id])
        end

        render :json => posts, each_serializer: NewsfeedSerializer
      end

      ### ----- END Training REQUESTS ----- ###

      ### ----- START Training REQUESTS ----- ###

      def quizzes
        if params[:before].presence
          posts = Post.where("org_id = ? AND post_type IN (?) AND id < ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("quiz"),
            params[:before],
            @user[:location],
            @user[:user_group],
            Time.now
          ).order("posts.updated_at asc")
        elsif params[:since].presence
          created_at = Post.find(params[:since]).created_at.to_s
          posts = Post.where("org_id = ? AND post_type IN (?) AND id > ? AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("quiz"),
            params[:since],
            @user[:location],
            @user[:user_group],
            Time.now
          ).order("posts.updated_at asc")
        else
          posts = Post.where("org_id = ? AND post_type IN (?) AND location = ? AND user_group = ? AND is_valid AND created_at <= ?",
            @user[:active_org],
            PostType.reference_by_base_type("quiz"),
            @user[:location],
            @user[:user_group],
            Time.now
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
        if @user.gallery_image.presence
          @user.gallery_image.each do |p|
            p.check_user(params[:user_id])
          end
        end

        if @user.profile_image.presence
          @user.profile_image.check_user(params[:user_id])
        end

        render json: @user, serializer: UserGallerySerializer
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
          Mession.broadcast(@post[:org_id], "open_app", "join", 4, @post[:id], @user[:id], @user[:id])
        end

        render :json => @user, serializer: UserProfileSerializer
      end

      def manage_user
        @user[:location] = params[:location] if params[:location].present?
        @user[:user_group] = params[:user_group] if params[:user_group].present?
        @user[:phone_number] = params[:number] if params[:number].present?
        if @user.save!
          render json: { "eXpresso" => { "code" => 1, "message" => "User update success." } }
        else
          render json: { "eXpresso" => { "code" => -126, "message" => "User update failed." } }
        end
      end

      def manage_group_user
        if params[:locations].present?
          if User.where(:id => params[:ids]).update_all(:location => params[:locations])
            render json: { "eXpresso" => { "code" => 1, "message" => "User bulk update success." } }
          else
            render json: { "eXpresso" => { "code" => -127, "message" => "User bulk update failed." } }
          end
        elsif params[:user_groups].present?
          if User.where(:id => params[:ids]).update_all(:user_group => params[:user_groups])
            render json: { "eXpresso" => { "code" => 1, "message" => "User bulk update success." } }
          else
            render json: { "eXpresso" => { "code" => -127, "message" => "User bulk update failed." } }
          end
        end
      end

      def make_admin
        @privilege = UserPrivilege.where(:org_id => params[:org_id], :owner_id => params[:id]).first

        if @privilege.toggle!(:is_admin)
          render json: { "eXpresso" => { "code" => 1, "message" => @privilege[:is_admin] } }
        else
          render json: { "eXpresso" => { "code" => -128, "message" => "User admin status failed to update." } }
        end
      end

      def revolk_users
        success ||= Array.new
        @users = User.where(:id => params[:ids])
        @users.each do |user|
          success.push(user[:id]) if user.revolk_account
          #success.push(user[:id]) if user
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "Success", "successids" => success } }
      end

      #def destroy
      #  @user = User.find(params[:id])
      #  if @user.update(:is_valid => false)
      #    render :json => @user, serializer: UserProfileSerializer
      #  else
      #    render :json => @user.errors
      #  end
      #end

      # Fetches the list of users belonging to the same org as the caller
      # Called on the members objects of the User class
      # => params[:id] = id of the calling user
      # => @user = fetched according to params[:id], and used to set the network id of the query
      # Returns json object containing array of user objects serialized by serializers/user_profile_serializer.rb
      def contact_list
        @users = User.where("active_org = ? AND id != ? AND is_valid", @user[:active_org], @user[:id]).order("first_name ASC, last_name ASC")
        @users.each do |p|
          if p.profile_image.presence
            p.profile_image.check_user(params[:user_id]) # set the serilizer up with the caller id to check for likes
          end
        end
        render json: @users, each_serializer: UserProfileSerializer
      end

      # Fetches the list of active chat sessions involving the user
      # Called on the members objects of the User class
      # => params[:id] = id of the calling user
      # Returns json object containing array of chat_session objects serialized by serializers/chat_session_serializer.rb
      def chat_list
        session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
        @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc")

        render json: @sessions, each_serializer: ChatSessionSerializer
      end

      # Resets the password for the user with provided email address via email (no mobile session required)
      # => params[:email] = email of the account to be resetted
      # Returns error code -108 or 1 for success
      def reset_password
        if params[:email].present?
          #phone_number = params[:email].sub("@coffeemobile.com","")
          user = User.find_by_email(params[:email])
          if user && user.send_password_reset
            #UserAnalytic.create(:action => 10, :org_id => user[:active_org], :user_id => user[:id], :ip_address => request.remote_ip.to_s)
            render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully reset" } }
          else
            render json: { "eXpresso" => { "code" => -108, "message" => "Something went wrong." } }
          end
        elsif params[:phone_number].present?
          user = User.find_by_phone_number(params[:phone_number])
          if user && user.send_password_reset_via_sms
            #UserAnalytic.create(:action => 10, :org_id => user[:active_org], :user_id => user[:id], :ip_address => request.remote_ip.to_s)
            render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully reset" } }
          else
            render json: { "eXpresso" => { "code" => -108 } }
          end
        else
          user = false
          render json: { "eXpresso" => { "code" => -108, "message" => "Cannot find user." } }
        end
      end
      #def reset_password
      #  user = User.find_by_email(params[:email])
      #  if user && user.send_password_reset
      #    render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully reset" } }
      #  else
      #    render json: { "eXpresso" => { "code" => -108, "message" => user.errors } }
      #  end
      #end

      # Resets the password for the user from the settings screen
      # Called on the members objects of the User class
      # => params[:email] = email of the user who wants to reset the password
      # => params[:id] = id of the user who wants to reset the password
      # => params[:password] = current password of the user who wants to reset the password for authentication
      # => params[:new_password] = desired new password of the user
      # Returns error code -109 or 1 for success
      def change_password
        if User.exists?(:email => params[:email], :is_valid => true)
          @user = User.find_by_email_and_is_valid(params[:email], true)
          #UserAnalytic.create(:action => 10, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
          status = @user.authenticate(params[:password])
          Rails.logger.debug(status)
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

      def mass_invite_from_dashboard
        @organization = Organization.find(params[:org_id])
        if User.exists?(:email => params[:email].downcase)
          render json: { "eXpresso" => { "code" => -1 } }
        elsif Invitation.exists?(:email => params[:email].downcase, :is_valid => true)
          render json: { "eXpresso" => { "code" => 0 } }
        else

          if @invitation = Invitation.create(
              :first_name => params[:first_name],
              :last_name => params[:last_name],
              :email => params[:email].downcase,
              :phone_number => params[:phone_number],
              :user_group => params[:user_group],
              :location => params[:location],
              :org_id => params[:org_id],
              :owner_id => params[:owner_id],
              :is_invited => true
            )
            NotificationsMailer.invitation_email(params[:email], @organization[:name], @invitation).deliver
            render json: { "eXpresso" => { "code" => 1, "invitation_id" => @invitation[:id]} }
          else
            render json: { "eXpresso" => { "code" => -2} }
          end
        end
      end

      def invite_from_dashboard
        @added ||= Array.new
        @ignored = 0
        @organization = Organization.find(params[:org_id])
        params[:data].each do |user|

          if Invitation.exists?(:email => user[1][:email].downcase)
            @ignored = @ignored + 1
          elsif User.exists?(:email => user[1][:email].downcase)
            @ignored = @ignored + 1
          else
            if @invitation = Invitation.create(
              :first_name => user[1][:first_name],
              :last_name => user[1][:last_name],
              :email => user[1][:email].downcase,
              :phone_number => user[1][:phone_number],
              :user_group => user[1][:user_group],
              :location => user[1][:location],
              :org_id => params[:org_id],
              :owner_id => params[:owner_id],
              :is_invited => true
            )
              NotificationsMailer.invitation_email(user[1][:email].downcase, @organization[:name], @invitation).deliver
              @added.push(@invitation)
            else
              @ignored = @ignored + 1
            end
          end
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "Invitations sent", "added" => @added, "ignored" => @ignored } }
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

        message = @client.account.messages.create(
          #:body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they use to trade shifts and chat. It's called Coffee Mobile, download here: #{@host}",
          :body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they use to trade shifts and chat. Download Coffee Mobile here: #{@host}",
          :to => params[:phone],
          :from => "+16473602178"
        )
        if message
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

    end
  end
end
