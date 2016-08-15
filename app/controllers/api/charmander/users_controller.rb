include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class UsersController < ApplicationController
      class User < ::User
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:validate_user]
      before_filter :validate_session, :except => [:verify, :invite_from_dashboard, :manage_user, :join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password, :logout, :reindex]
      before_filter :fetch_user, :except => [:verify, :index, :join_org, :set_admin, :reset_password, :reindex]

      respond_to :json

      def reindex
        #User.all.each do |usr|
        User.where(:last_recount => nil).each do |usr|
          usr.recalculate_scores
        end
      end

      def test_sidekiq
        TestWorker.perform_async(true)
        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end

      def claim_reward
        @claim = Claim.new(
          :user_id => params[:id],
          :referred_count_required_for_claim => params[:claim_count],
          :status => "VERIFYING",
          :claim_amount => params[:claim_amount],
          :email => params[:email],
          :verified => false
        )
        if @claim.save
          render json: { "eXpresso" => { "code" => 1, "message" => "Success", "verification_code" => @claim[:verification_code], "claim_id" => @claim[:claim_id] } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, your claim could not be processed at this moment.", "error" => "Could not save info, probably server." } }
        end
      end

      def contact_dump
        if params[:id].present?
          user_id = params[:id]
        else
          user_id = 0
        end
        count = 0

        params[:contacts].each do |contact|
          begin
            if contact[:phones].present?
              phone_numbers = contact[:phones].map(&:inspect).join(', ').gsub(/[\(\)\-\+\s\u00a0]/i, '')
            else
              phone_numbers = nil
            end

            if contact[:emails].present?
              emails = contact[:emails].map(&:inspect).join(', ')
            else
              emails = nil
            end

            if contact[:social_profiles].present?
              socials = contact[:social_profiles].map(&:inspect).join(', ')
            else
              socials = nil
            end
            ContactDump.create(
              :user_id => user_id,
              :phone_numbers => phone_numbers,
              :first_name => contact[:first_name],
              :last_name => contact[:last_name],
              :emails => emails,
              :social_links => socials,
              :processed => false
            )
            count = count + 1
          rescue => e
            Rails.logger.debug("============ERROR START users:contact_dump ============")
            Rails.logger.debug(e.message)
            Rails.logger.debug(e.backtrace.join("\n"))
            Rails.logger.debug("============ERROR END users:contact_dump ============")
            count = count - 1
          ensure
          end
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} records processed" } }
      end

      def verify_claim
        if Claim.exists?(:claim_id => params[:claim_id])
          @claim = Claim.where(:claim_id => params[:claim_id]).first
          if @claim.update_attributes(:verified => true, :status => "PROCESSING")
            @user = User.find(@claim[:user_id])
            if @user.process_verified_claim("DEFAULT", @claim[:referred_count_required_for_claim])
              @claim.update_attributes(:verified => true, :status => "DENIED")
              render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, you do not have enough referrals that you can claim a reward for. Contact our team if this is not correct at hello@myshyft.com", "error" => "Not enough referral unclaimed" } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The verification failed" } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Cannot find the claim" } }
        end
      end

      def create_referral_link
        @referral = ReferralSend.new(
          :sender_id => params[:id],
          :program_code => params[:program_code].present? ? params[:program_code] : "DEFAULT",
          :referral_link => params[:referral_link],
          :referral_platform => params[:referral_platform].present? ? params[:referral_platform] : "DIRECT",
          :referral_code => params[:referral_code].present? ? params[:referral_code] : @user.get_referral_code,
          :referral_target_id => params[:referral_target_id]
        )
        if @referral.save
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, we could not create the referral information at this moment.", "error" => "Could not save info, probably server." } }
        end
      end

      def get_referral_code
        if User.exists?(:id => params[:id], :is_valid => true)
          @user = User.find(params[:id])
          code = @user.get_referral_code
          count = @user.get_referral_count("DEFAULT")
          claims = @user.get_current_claim
          render json: { "eXpresso" => {
            "code" => 1,
            "program_code" => "DEFAULT",
            "referral_code" => code,
            "referral_count" => count % 5,
            "claimable_amount" => (count / 5) * 5,
            "processing_claim" => claims,
            #"referral_screen_display" => "Shyft works better when your coworkers are using it too...",
            "referral_screen_display" => "Click to copy the link and share Shyft with your friends and coworkers!",
            "referral_facebook_message" => "Hey! Check out Shyft, the app we are using for shift swaps and sharing schedules. It is completely free, you can get it here: [LINK HERE]",
            "referral_twitter_message" => "Hey! Check out Shyft, the app we are using for shift swaps and sharing schedules. It is completely free, you can get it here: [LINK HERE]",
            "referral_social_message" => "Hey! Check out Shyft, the app we are using for shift swaps and sharing schedules. It is completely free, you can get it here: [LINK HERE]",
            #"referral_chat_message" => "Hey! Check out Shyft, the app we are using for shift swaps and sharing schedules. It is completely free, you can get it here: [LINK HERE]",
            "referral_chat_message" => "Hey! We're using Shyft at work to swap shifts and post schedules now. It's free, download it here: [LINK HERE]",
            "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, we couldn't get your referral information at this moment.", "error" => "User with ID #{params[:id]} does not exist." } }
        end
      end

      def get_referred_users
        if User.exists?(:id => params[:id], :is_valid => true)
          @user = User.find(params[:id])
          code = @user.get_referral_code
          @referred = ReferralAccept.where(:referral_code => code)

          render json: @referred, each_serializer: ReferredUserSerializer
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, we couldn't get your referral information at this moment.", "error" => "User with ID #{params[:id]} does not exist." } }
        end
      end

      def fetch_user
        if User.exists?(:id => params[:id])
          @user = User.find_by_id(params[:id])
        end
      end

      def profile
        render json: @user, serializer: UserProfileSerializer
      end

      def flash_action
        if User.exists?(:id => params[:id], :is_valid => true)
          FlashMessageResponse.create(:user_id => params[:user_id], :flash_message_uid => params[:uid], :clicked => params[:clicked])

          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, action could not be performed.", "error" => "User with ID #{params[:id]} does not exist." } }
        end
      end

      def fetch_shifts
        UserAnalytic.create(:action => 101, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        @subscriptions = Subscription.where(:is_active => true, :user_id => @user[:id]).pluck(:channel_id)
        @shyfts = ScheduleElement.where("start_at >= '#{params[:startDate]}' AND start_at <= '#{params[:endDate]}' AND channel_id IN (#{@subscriptions.join(", ")})")

        render json: @shyfts, each_serializer: ShiftSerializer
      end

      def synchronize
        #Log the action
        UserAnalytic.create(:action => 4, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)

        _BASIC_POST_TYPE_IDS = "5,6,7,8,9"
        _ANNOUNCEMENT_POST_TYPE_IDS = "1,2,3,4,10"
        _TRAINING_POST_TYPE_IDS = "11,12,13,18"
        _QUIZ_POST_TYPE_IDS = "14,15"
        _SAFETY_TRAINING_POST_TYPE_IDS = "16"
        _SAFETY_QUIZ_POST_TYPE_IDS = "17"
        _SCHEDULE_POST_TYPE_IDS = "19,20"

        fetch_size = params[:size].present? ? params[:size] : 15
        fetch_all = params[:options].present? ? false : true
        fetch_time = params[:last_sync_time].present? ? Time.zone.parse(params[:last_sync_time]) : Time.now
        fetch_fresh = params[:last_sync_time].present? ? false : true
        fetch_history = params[:before].present? ? true : false

        result = {}
        #result["server_sync_time"] = DateTime.now.iso8601(3)
        #result["flash_alert"] = { "uid" => "16818e151fc45d95ae3634a50da9d783", "message" => "Having trouble getting your shifts covered? <u>Shyft</u> works well with lots of coworkers on your network, <b>invite some coworkers</b> and see your shifts covered instantly!", "button" => "INVITE COWORKERS", "target" => "contact_invite"}
        result["server_sync_time"] = Time.now.utc
        result["subscriptions"] ||= Array.new
        result["shifts"] ||= Array.new
        result["schedules"] ||= Array.new
        result["contacts"] ||= Array.new
        result["notifications"] ||= Array.new
        result["sessions"] ||= Array.new
        channels ||= Array.new

        if fetch_fresh
          @subscriptions = Subscription.where("user_id =#{@user[:id]} AND is_valid AND is_active").order("updated_at desc")
        else
          @subscriptions = Subscription.where(["user_id =#{@user[:id]} AND updated_at > ?", fetch_time]).order("updated_at desc")
        end
        #@subscriptions = Subscription.where(:user_id => @user[:id], :is_valid => true)
        @subscriptions.each do |s|
          #s.check_parameters(fetch_time, fetch_fresh)
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
          #subscription.update_attribute(:subscription_last_synchronize, Time.now)
          channels.push(subscription[:channel_id])
        end

        # -- START FETCH CONTACT INFORMATION -- #
        if fetch_all || params[:options][:contacts].present?
          location_list = UserPrivilege.where("owner_id = #{@user[:id]} AND is_valid = 't' AND is_approved='t' AND location_id IS NOT NULL AND is_invisible = 'f'").pluck(:location_id)
          if location_list.count > 0
              if fetch_fresh
                #@contacts = User.where("id IN (#{contact_ids.join(", ")}) AND is_valid")
                @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_valid AND is_approved")
              else
                #@contacts = User.where("id IN (#{contact_ids.join(", ")}) AND updated_at > '#{fetch_time}' AND is_valid")
                @contacts = UserPrivilege.where("location_id IN (#{location_list.join(", ")}) AND owner_id != #{@user[:id]} AND NOT is_invisible AND is_approved AND updated_at > '#{fetch_time}'")
              end
              @contacts.map do |contact|
                #result["contacts"].push(SyncContactSerializerTwo.new(contact, root: false))
                result["contacts"].push(SyncContactThruPrivilegeSerializer.new(contact, root: false))
              end
            #end
          end
        else
          #skip because it is not specified to have this in the result
        end
        # -- END FETCH CONTACT INFORMATION -- #

        if fetch_all || params[:options][:sessions].presence
          session_ids = ChatParticipant.where(:user_id => params[:id], :is_active => true).pluck(:session_id)
          if fetch_fresh
            @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc").limit(55)
          else
            @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active AND updated_at > ?", session_ids, fetch_time]).order("updated_at desc")
          end
          @sessions.map do |session|
            result["sessions"].push(SyncChatSerializer.new(session, root: false))
          end
        else
          #skip because it is not specified to have this in the result
        end

        # -- START FETCH SCHEDULES -- #
        if fetch_all || params[:options][:schedules].presence
          if channels.size > 0
            if fetch_fresh
              @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND is_valid",
                params[:user_id]
              ).order("posts.updated_at desc").limit(15)
            else
              @schedules = Post.where("(z_index < 9999 OR owner_id = ?) AND post_type IN (#{_SCHEDULE_POST_TYPE_IDS}) AND channel_id IN (#{channels.join(", ")}) AND updated_at > ?",
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

        render json: { "eXpresso" => result }
        @subscriptions.map do |subscription|
          subscription.update_attribute(:subscription_last_synchronize, Time.now)
        end
      end

      def change_password
        if User.exists?(:email => params[:email], :is_valid => true)
          @user = User.find_by_email_and_is_valid(params[:email], true)
          #UserAnalytic.create(:action => 10, :org_id => @user[:active_org], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
          status = @user.authenticate_location_based(params[:password])
          if status == 200
            @user.change_password(params[:new_password])
            render json: { "eXpresso" => { "code" => 1, "message" => "Password successfully changed" } }
          else
            render json: { "eXpresso" => { "code" => -109, "message" => @user.errors } }
          end
        end
      end

      def deactivate
        if User.exists?(:id => params[:id], :is_valid => true)
          @user = User.find(params[:id])
          @user.update_attribute(:is_valid, false)
          render json: { "eXpresso" => { "code" => 1, "message" => "Account successfully deleted" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "User account does not exist", "error" => "Cannot find user account" } }
        end
      end

      def invite_from_contact
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token

        if params[:referral_link].present?
          @host = params[:referral_link]
        elsif Rails.env.production?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.staging?
          @host = "http://goo.gl/isddrw"
        elsif Rails.env.testing?
          @host = "http://goo.gl/isddrw"
        else
          @host = "http://goo.gl/isddrw"
        end

        begin
          ReferralSend.create(
            :sender_id => params[:id],
            :program_code => params[:program_code].present? ? params[:program_code] : "DEFAULT",
            :referral_link => @host,
            :referral_platform => "TWILIO",
            :referral_code => params[:referral_code].present? ? params[:referral_code] : @user.get_referral_code,
            :referral_target_id => params[:phone]
          )
        rescue
        ensure
        end

        message_body = "Hi"
        if params[:name].present?
          if Obscenity.profane?(params[:name])
            message_body = "Hey we are using Shyft to swap shifts and share schedules. The rest of the team is already on it: #{@host} - #{@user[:first_name]} #{@user[:last_name]}."
          else
            message_body = "Hey #{params[:name]}, we are using Shyft to swap shifts and share schedules. The rest of the team is already on it: #{@host} - #{@user[:first_name]} #{@user[:last_name]}."
          end
        else
          message_body = "#{@user[:first_name]} #{@user[:last_name]} has invited you to download the app they use to trade shifts and chat. Download Shyft here: #{@host}"
        end

        #phone_number = params[:phone].gsub(/[\+\-\(\)\s]/,'')
        phone_number = params[:phone].gsub(/\W/,'')


        begin
          message = @client.account.messages.create(
            :body => message_body,
            #:body => "#{@user.first_name} #{@user.last_name} has invited you to download the app they use to trade shifts and chat. Download Shyft here: #{@host}",
            :to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
            :from => "+16473602178"
          )
          if message
            render json: { "eXpresso" => { "code" => 1, "message" => "Invitation sent" } }
          else
            render json: { "eXpresso" => { "code" => -111, "message" => message.errors } }
          end
        rescue Twilio::REST::RequestError => e
          ErrorLog.create(
            :file => "users_controller.rb",
            :function => "invite_from_contact",
            :error => "#{e}")
          render json: { "code" => -1, "message" => "Ops...Something went wrong!.", "error" => "Shouldn't land here but it did."}
        end
      end

    end
  end
end
