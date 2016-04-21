include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class ChannelsController < ApplicationController
      class Channel < ::Channel
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers

      respond_to :json

      def set_require_shift_approval
        if Channel.exists?(:id => params[:id])
          @channel = Channel.find(params[:id])
          if Subscription.exists?(:channel_id => params[:id], :user_id => params[:user_id], :is_admin => true, :is_valid => true, :is_active => true)
            if @channel.update_attribute(:shift_trade_require_approval, params[:require_approval])
              render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "Something went wrong! We were unable to turn on the require approval for shift trade option. Try again later" } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "You are not an admin of the Channel, you can't do this!", "error" => "User does not have the proper admin privilege proceed." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The group you are trying to become and admin for does not exist.", "error" => "Could not find channel with ID #{params[:id]}." } }
        end
      end

      def fetch_location_member_count
        @locations = Location.where(["google_map_id in (#{params[:google_map_ids]})"])
        if @locations.size > 0
          render json: @locations, each_serializer: LocationSearchResultSerializer
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Empty result set" } }
        end
      end

      def send_admin_claim(uid, lid, email)
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token
        @user = User.find(uid)
        message = @client.account.messages.create(
          :body => "Admin claim: #{@user[:first_name]} #{@user[:last_name]} / cell : #{@user[:phone_number]} / id: #{@user[:id]} / #{email} / location: #{lid}",
          :to => "+14252456668",
          :from => "+16137028842"
        )
        if message
          return 1
        else
          return 2
        end
      end

      def send_admin_claim_email(uid,cid,email,first_name)
        @claim = AdminClaim.new(
          :user_id => uid,
          :ref_type => 1,
          :ref_id => cid,
          :email => email,
          :activation_code => SecureRandom.urlsafe_base64,
          :is_active => true,
          :is_valid => true
        )
        if @claim.save
          NotificationsMailer.admin_claim_confirmation_email(email,first_name,@claim[:activation_code]).deliver
          1
        else
          2
        end
      end

      def i_am_admin
        if Channel.exists?(:id => params[:id])
          @channel = Channel.find(params[:id])
          if @channel[:channel_type] == "location_feed"
            if Subscription.exists?(:channel_id => @channel[:id].to_i, :user_id => params[:user_id], :is_valid => true)
              @user = User.find(params[:user_id])
              #self.send_admin_claim(params[:user_id], @channel[:id].to_i, params[:email])
              self.send_admin_claim_email(params[:user_id], @channel[:id], params[:email],@user[:first_name])
              render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
            else
              render json: { "eXpresso" => { "code" => -1, "message" => "You do not belong to this group and therefore cannot become an admin. Contact hello@myshyft.com if this is an error.", "error" => "User does not have the proper privilege key to proceed." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The group you are trying to become and admin for does not need an admin.", "error" => "Channel with ID #{params[:id]} is not a location feed." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The group you are trying to become and admin for does not exist.", "error" => "Could not find channel with ID #{params[:id]}." } }
        end
      end

      def remove_subscriber
        if Channel.exists?(:id => params[:id])
          @channel = Channel.find(params[:id])
          @sub = Subscription.where(:channel_id => @channel[:id], :user_id => params[:user_id], :is_valid => true, :is_active => true).first
          if @channel[:channel_type] == "location_feed"
            @key = UserPrivilege.where(:location_id => @channel[:channel_frequency].to_i, :owner_id => params[:user_id], :is_valid => true).first
          end
          if @channel[:owner_id].to_i == params[:user_id].to_i || (@channel[:channel_type] == "location_feed" && @key[:is_admin] == true) || @sub[:is_admin] == true
            if @channel[:owner_id].to_i == params[:remove_id].to_i
              render json: { "eXpresso" => { "code" => -1, "message" => "You cannot remove the group owner from the group.", "error" => "User with ID #{params[:remove]} is the channel owner." } }
            else
              if Subscription.exists?(:channel_id => params[:id], :user_id => params[:remove_id], :is_valid => true, :is_active => true)
                @subscription = Subscription.where(:channel_id => params[:id], :user_id => params[:remove_id], :is_valid => true).first
                @subscription.update_attributes(:is_valid => false, :is_active => false)
                if @channel[:channel_type] == "location_feed"
                  @target_key = UserPrivilege.where(:location_id => @channel[:channel_frequency].to_i, :owner_id => params[:remove_id], :is_valid => true).first
                  if @target_key[:is_admin]
                    render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, you cannot remove another admin. Please contact hello@myshyft.com for assitance with this action." } }
                  else
                    @target_key.update_attributes(:is_valid => false, :is_approved => false)
                    @subscription.notify_removed(@channel)
                    @channel.recount
                    render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
                  end
                else
                  @subscription.notify_removed(@channel)
                  @channel.recount
                  render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
                end
              else
                APILogger.info "[channel.remove_subscriber] subscription of user with ID #{params[:remove_id]} does not exist."
                render json: { "eXpresso" => { "code" => -1, "message" => "The user you're trying to remove is not in your group.", "error" => "Target user does not have subscription to channel with ID #{params[:id]}." } }
              end
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "Only the owner of the group can remove members from the group.", "error" => "User with ID #{params[:user_id]} is not the channel owner." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "The group you are trying to remove the user from does not exist.", "error" => "Could not find channel with ID #{params[:id]}." } }
        end
      end

      def add_subscriber
        if params[:subscriber_ids].present?
          if Channel.exists?(:id => params[:id])
            @channel = Channel.find(params[:id])
            if @channel[:channel_type] == "location_feed"
              render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, you cannot add a user to a location. But you can send them an invitation to join the location instead.", "error" => "Could not add the users" } }
            else
              if @channel.add_subscribers(params[:subscriber_ids])
                @channel.recount
                render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
              else
                render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, there was an error adding users to the channel. The Coffee team has been notified, please try again later.", "error" => "Could not add the users" } }
              end
            end
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "The group you are trying to add user(s) to does not exist.", "error" => "Could not find channel with id #{params[:id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "You must add at least 1 new user", "error" => "The list of IDs is empty." } }
        end
      end

      def list_subscribers
        if Subscription.exists?(:id => params[:subscription_id], :user_id => params[:user_id], :is_valid => true)
          if @channel = Channel.find(params[:id])
            @subscribers = Subscription.where(:channel_id => params[:id], :is_valid => true, :is_active => true, :is_invisible => false)
            render json: @subscribers, each_serializer: ChannelSubscribersSerializer
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, there was an error retrieving the user list. The Coffee team has been notified, please try again later.", "error" => "Cannot find channel with id #{params[:id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, you do not have permission to perform this action.", "error" => "Cannot find valid subscription belonging to channel with id #{params[:subscription_id]}." } }
        end
      end

      def list_admins
        if Subscription.exists?(:channel_id => params[:id], :user_id => params[:user_id], :is_valid => true)
          if @channel = Channel.find(params[:id])
            @admins = Subscription.where(:channel_id => params[:id], :is_valid => true, :is_active => true, :is_invisible => false, :is_admin => true)
            render json: @admins, each_serializer: ChannelSubscribersSerializer
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, there was an error retrieving the user list. The Coffee team has been notified, please try again later.", "error" => "Cannot find channel with id #{params[:id]}." } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Sorry, you do not have permission to perform this action.", "error" => "Cannot find valid subscription belonging to channel with id #{params[:subscription_id]}." } }
        end
      end

      def create
        if params[:participant_count].to_i >= 1
          self_assembled_channel = Channel.create(
            :channel_type => "custom_feed",
            :channel_frequency => SecureRandom.hex,
            :channel_name => params[:channel_name],
            :owner_id => params[:participants][0][:id]
          )

          if params[:channel_profile_url].present?
            @image = Image.new(
              :org_id => 1,
              :owner_id => params[:participants][0][:id],
              :image_type => 1
            )
            @image.avatar_remote_url = params[:channel_profile_url]
            if @image.save
              self_assembled_channel[:channel_profile_id] = @image[:id]
            end
          end

          @user = User.find(params[:participants][0][:id])
          @user.update_attributes(:shyft_score => @user[:shyft_score] + 5)
          message = @user[:first_name] + " " + @user[:last_name] + " has invited you to the private group \"#{self_assembled_channel[:channel_name]}\"."

          if self_assembled_channel.setup_subscriptions_to_custom_channel(params[:participants], message)
            self_assembled_channel.create_welcome_message
            if @subscription = Subscription.where(:channel_id => self_assembled_channel[:id], :user_id => @user[:id]).first
              #@subscription.check_parameters(Time.now.utc, true, true)
              @subscription.update_attribute(:is_admin, true)
              @subscription.check_parameters(Time.now.utc, true, true)
              render json: @subscription, serializer: SyncSubscriptionSerializer
            else
              render json: { "eXpresso" => { "code" => -1, "error" => self_assembled_channel.errors, "message" => "There was an error setting up the channel." } }
            end
          else
            render json: { "eXpresso" => { "code" => -1, "error" => self_assembled_channel.errors, "message" => "There was an error setting up the channel." } }
          end
        else

        end
      end

      def profile
        _TRAINING_POST_TYPE_IDS = "11,12,13,18"
        _QUIZ_POST_TYPE_IDS = "14,15"
        _SAFETY_TRAINING_POST_TYPE_IDS = "16"
        _SAFETY_QUIZ_POST_TYPE_IDS = "17"

        if Channel.exists?(params[:id])
          @channel = Channel.find(params[:id])

          render json: @channel, serializer: ChannelProfileSerializer
        end
      end

      def recount_members
        count = 0
        Channel.all.each do |channel|
          channel.recount
          count = count + 1
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} records updated" } }
      end

      def recount_geo_region_channel
        opt_out = 0
        opt_in = 0
        channel = Channel.find(params[:id])

        coordinate = channel[:channel_frequency].split(":")[1].split(",")

        distance = channel[:channel_frequency].split(":")[2]

        #Rails.logger.debug("LOOKING AT #{coordinate} WITHIN #{distance}")

        Location.where("(lng IS NOT NULL AND lng != '') AND (lat IS NOT NULL AND lat != '') AND is_valid").each do |location|
          #Rails.logger.debug("DISTANCE between #{coordinate} AND #{location[:lng]} #{location[:lat]}")
          #Rails.logger.debug(Location.distance_between([coordinate[0].to_f,coordinate[1].to_f], [location[:lng].to_f,location[:lat].to_f]))
          #if Geocoder::Calculations.distance_between(coordinate, "#{location[:lng]},#{location[:lat]}").to_f < distance.to_f
          if Location.distance_between([coordinate[1].to_f,coordinate[0].to_f], [location[:lat].to_f,location[:lng].to_f]) < distance.to_f
            #Rails.logger.debug("FOUND LOCATION WITHIN RANGE")
            @keys = UserPrivilege.where(:location_id => location[:id])
            @keys.each do |key|
              if !Subscription.exists?(:user_id => key[:owner_id],:channel_id => channel[:id])
                region_subscription = Subscription.create(
                  :user_id => key[:owner_id],
                  :channel_id => channel[:id],
                  :is_active => true
                )
                opt_in = opt_in + 1
              else
                opt_out = opt_out + 1
              end
            end
          end
        end
        channel.recount
        render json: { "eXpresso" => { "code" => 1, "message" => "#{opt_out} opt outs | #{opt_in} opt ins | #{channel.member_count} members total " } }
      end

      def recount_branded_geo_region_channel
        opt_out = 0
        opt_in = 0
        channel = Channel.find(params[:id])

        brand = channel[:channel_frequency].split(":")[1]

        coordinate = channel[:channel_frequency].split(":")[2].split(",")

        distance = channel[:channel_frequency].split(":")[3]

        #Rails.logger.debug("LOOKING AT #{coordinate} WITHIN #{distance}")

        Location.where("(lng IS NOT NULL AND lng != '') AND (lat IS NOT NULL AND lat != '') AND is_valid AND lower(location_name) like '%#{brand}%'").each do |location|
          #Rails.logger.debug("DISTANCE between #{coordinate} AND #{location[:lng]} #{location[:lat]}")
          #Rails.logger.debug(Location.distance_between([coordinate[0].to_f,coordinate[1].to_f], [location[:lng].to_f,location[:lat].to_f]))
          #if Geocoder::Calculations.distance_between(coordinate, "#{location[:lng]},#{location[:lat]}").to_f < distance.to_f
          if Location.distance_between([coordinate[1].to_f,coordinate[0].to_f], [location[:lat].to_f,location[:lng].to_f]) < distance.to_f
            #Rails.logger.debug("FOUND LOCATION WITHIN RANGE")
            @keys = UserPrivilege.where(:location_id => location[:id])
            @keys.each do |key|
              if !Subscription.exists?(:user_id => key[:owner_id],:channel_id => channel[:id])
                region_subscription = Subscription.create(
                  :user_id => key[:owner_id],
                  :channel_id => channel[:id],
                  :is_active => true
                )
                opt_in = opt_in + 1
              else
                opt_out = opt_out + 1
              end
            end
          end
        end
        channel.recount
        render json: { "eXpresso" => { "code" => 1, "message" => "#{opt_out} opt outs | #{opt_in} opt ins | #{channel.member_count} members total " } }
      end

      def recount_location_region_channel
        opt_out = 0
        opt_in = 0
        channel = Channel.find(params[:id])

        locations = channel[:channel_frequency].split(":")[1].split("|")

        locations.each do |lid|
          if Location.exists?(:id => lid.to_i)
            location = Location.find(lid.to_i)
            @keys = UserPrivilege.where(:location_id => location[:id])
            @keys.each do |key|
              if !Subscription.exists?(:user_id => key[:owner_id],:channel_id => channel[:id])
                region_subscription = Subscription.create(
                  :user_id => key[:owner_id],
                  :channel_id => channel[:id],
                  :is_active => true
                )
                opt_in = opt_in + 1
              else
                opt_out = opt_out + 1
              end
            end
          end
        end
        channel.recount
        render json: { "eXpresso" => { "code" => 1, "message" => "#{opt_out} opt outs | #{opt_in} opt ins | #{channel.member_count} members total " } }
      end

      def recount_category_channel
        opt_out = 0
        opt_in = 0
        channel = Channel.find(params[:id])

        category = channel[:channel_frequency].split(":")[1]
        Rails.logger.debug(category)
        if Location.exists?(["category in #{category}"])
          @locations = Location.where("category in #{category}")
          @keys = UserPrivilege.where(["location_id in (#{@locations.pluck(:id).join(',')})"])
          @keys.each do |key|
            if !Subscription.exists?(:user_id => key[:owner_id],:channel_id => channel[:id])
              region_subscription = Subscription.create(
                :user_id => key[:owner_id],
                :channel_id => channel[:id],
                :is_active => true
              )
              opt_in = opt_in + 1
            else
              opt_out = opt_out + 1
            end
          end
        end

        channel.recount
        render json: { "eXpresso" => { "code" => 1, "message" => "#{opt_out} opt outs | #{opt_in} opt ins | #{channel.member_count} members total " } }
      end

      def assign_latest_message
        count = 0
        Channel.all.each do |channel|
          if channel.channel_type.include? "_feed"
            post = Post.where(:channel_id => channel[:id]).order('created_at DESC').limit(1).first
            owner = User.find(post[:owner_id]) if post
            if post && owner
              if post[:content].size == 0
                message = owner[:first_name] + " " + owner[:last_name] + ": #{post[:title]}"
              else
                message = owner[:first_name] + " "  + owner[:last_name] + ": #{post[:content]}"
              end
              channel.update_attribute(:channel_latest_content, message)
              count = count + 1
            end
          end
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} records updated" } }
      end

      def fix_channel_posts
        count = 0
        counta = 0
        Post.all.each do |post|
          if post[:org_id] == 1 && post[:location] != 0
            if channel = Channel.where(:channel_type => "location_feed", :channel_frequency => post[:location].to_s).first
              post.update_attribute(:channel_id,channel[:id])
              count = count + 1
            end
          elsif post[:org_id] == 1 && post[:location] == 0
            post.update_attribute(:channel_id,1)
            count = count + 1
          elsif post[:org_id] != 1
            if channel = Channel.where(:channel_type => "organization_feed", :channel_frequency => post[:org_id].to_s).first
              post.update_attribute(:channel_id,channel[:id])
              count = count + 1
            end
          else
            post.update_attribute(:channel_id,1)
            counta = counta + 1
          end
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} records updated, #{counta} ambiguous records also updated" } }
      end

      def fix_channel_chats
        channel_count = 0
        subscriptions_count = 0
        ChatSession.all.each do |session|
          if chat_channel = Channel.create(
              :channel_type => "user_chat",
              :channel_frequency => session[:id].to_s,
              :owner_id => 134,
              :channel_latest_content => session[:latest_message],
              :channel_content_count => session[:message_count],
              :is_valid => session[:is_valid],
              :is_active => session[:is_valid],
              :is_public => false
            )
            channel_count = channel_count + 1
            ChatParticipant.where(:session_id => session[:id]).each do |participant|
              if chat_subscription = Subscription.create(
                  :user_id => participant[:user_id],
                  :channel_id => chat_channel[:id],
                  :is_valid => participant[:is_active]
                )
                subscriptions_count = subscriptions_count + 1
              end
            end
            chat_channel.recount
          end
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "#{channel_count} chat sessions, #{subscriptions_count} chat subscription" } }
      end

    end
  end
end
