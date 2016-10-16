include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class MessionsController < ApplicationController
      class Mession < ::Mession
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(thumb_url: self.thumb_url, gallery_url: self.gallery_url, full_url: self.full_url)
        #end
      end

      before_filter :restrict_access, :set_headers

      respond_to :json

      def send_batch_noification
        @users = User.where("id = 54493 OR id = 12799")
        ios_counter = 0
        gcm_counter = 0
        @users.each do |user|
          begin
            @mession = Mession.where(:user_id => user[:id], :is_valid => true).order("created_at DESC").first
            if @mession.push_to == "GCM"
              n = Rpush::Gcm::Notification.new
              n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
              n.registration_ids = @mession.push_id
              #n.attributes_for_device =
              n.data = {
                :category => "open_app",
                :message => params[:message],
                :org_id => 1,
                :source => 1,
                :source_id => 1
              }
              n.save!
              gcm_counter = gcm_counter + 1
            end

            if @mession.push_to == "APNS"
              n = Rpush::Apns::Notification.new
              n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
              n.device_token = @mession.push_id
              n.alert = params[:message]
              #n.attributes_for_device
              n.data = {
                :act => "open_app", # Take out in future
                :cat => "open_app",
                :oid => 1,
                :src => 1,
                :sid => 1
              }
              n.save!
              ios_counter = ios_counter + 1
            end
          rescue

          end
        end

        render json: { "eXpresso" => { "code" => 1, "message" => "GCM: #{gcm_counter} iOS: #{ios_counter}" } }
      end

      def send_custom_noification
        @user = User.where(:phone_number => params[:phone_number], :is_valid => true).first
        @mession = Mession.where(:user_id => @user[:id], :is_valid => true).first
        if @mession.push_to == "GCM"
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
          n.registration_ids = @mession.push_id
          #n.attributes_for_device =
          n.data = {
            :category => "open_app",
            :message => params[:message],
            :org_id => 1,
            :source => 1,
            :source_id => 1
          }
          if n.save!
            render json: { "eXpresso" => { "code" => 1, "message" => "done" } }
          else
            render json: { "eXpresso" => { "code" => -1, "message" => n.errors } }
          end
        end

        if @mession.push_to == "APNS"
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
          n.device_token = @mession.push_id
          n.alert = params[:message]
          #n.attributes_for_device
          n.data = {
            :cat => "open_app",
            :oid => 1,
            :source => 1,
            :source_id => 1
          }
          if n.save!
            render json: { "eXpresso" => { "code" => 1, "message" => "done" } }
          else
            render json: { "eXpresso" => { "code" => -1, "message" => n.errors } }
          end
        end
      end

      def send_referral_message
        @mession = Mession.find(params[:id])
        if @mession.push_to == "GCM"
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
          n.registration_ids = @mession.push_id
          #n.attributes_for_device =
          n.data = {
            :category => params[:category],
            :message => params[:message],
            :org_id => params[:org_id],
            :source => params[:source],
            :source_id => params[:source_id]
          }
          n.save!
        end

        if @mession.push_to == "APNS"
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
          n.device_token = @mession.push_id
          n.alert = params[:message]
          #n.attributes_for_device
          n.data = {
            :cat => params[:category],
            :oid => params[:org_id],
            :source => params[:source],
            :source_id => params[:source_id]
          }
          n.save!
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "done" } }
      end

      def create
        #if @user = User.find(:first, :conditions => ["lower(email) = ? AND is_valid", params[:email].downcase] )
        if @user = User.where("lower(email) = ? AND is_valid", params[:email].downcase).first
          if Mession.exists?(:id => params[:session_id], :user_id => @user[:id], :is_valid => true)
            @mession = Mession.where(:id => params[:session_id], :user_id => @user[:id], :is_valid => true).last

            status = @user.authenticate(params[:password])
            if status == 401
              render json: { "eXpresso" => { "code" => 401, "message" => "Invalid password" } }
            elsif status == 209
              render json: { "eXpresso" => { "code" => 209, "message" => "Account has not been validated" } }
            elsif status == 210
              render json: @mession, serializer: Mession210Serializer
            elsif status == 211
              render json: @mession, serializer: Mession210Serializer
            elsif status == 200
              if @mession[:org_id] == 0 && params[:mession][:org_id].presence
                @mession[:org_id] = params[:mession][:org_id]
              end
              ##UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
              render json: @mession, serializer: MessionSuccessSerializer
            else
              render json: { "eXpresso" => { "code" => 401, "message" => "Invalid password" } }
            end
          elsif @user[:system_user]
            #Mession.clean(@user[:id], params[:mession][:push_id], params[:mession][:device_id])

             @mession = Mession.new(
                :user_id => @user[:id],
                :org_id => @user[:active_org],
                :device => params[:mession][:device],
                :device_id => params[:mession][:device_id],
                :push_to => params[:mession][:push_to],
                :push_id => params[:mession][:push_id]
              )
              @mession.save

            render json: @mession, serializer: MessionSuccessSerializer
          else
            # mession has became inactive, see if a new one can be created
            #Mession.clean(@user[:id], params[:mession][:push_id], params[:mession][:device_id])
            status = @user.authenticate(params[:password])
            if status == 401
              render json: { "eXpresso" => { "code" => 401, "message" => "Invalid password" } }
            elsif status == 209
              render json: { "eXpresso" => { "code" => 209, "message" => "Account has not been validated" } }
            elsif status == 211
              render json: { "eXpresso" => { "code" => 211, "message" => "Account not approved" } }
            elsif status == 200 || status == 210


              @mession = Mession.new(
                :user_id => @user[:id],
                :org_id => @user[:active_org],
                :device => params[:mession][:device],
                :device_id => params[:mession][:device_id],
                :push_to => params[:mession][:push_to],
                :push_id => params[:mession][:push_id]
              )
              @mession.save
              if status == 200
                #UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
                render json: @mession, serializer: MessionSuccessSerializer
              else
                render json: @mession, serializer: Mession210Serializer
              end
            else
              render json: { "eXpresso" => { "code" => 404, "message" => "Unknown error" } }
            end
          end
        else
          # the user info given was invalid
          render json: { "eXpresso" => { "code" => 401, "message" => "Invalid password" } }
        end
      end

      def activate
          if Mession.exists?(:id => params[:id])
            @mession = Mession.find(params[:id])
            if @mession.update_attribute(:org_id, params[:org_id])
              @user = User.find(@mession[:user_id])
              @user.update_attribute(:active_org, params[:org_id])
              render :json => @mession, serializer: MessionSerializer
            else
              render :json => @mession.errors
            end
          end
      end

      def restrict_access
        #X-Method: cc5f43ea7132996963e9a62fabde3c6f
        #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

      def check_android_version
        if params[:version].to_i >= 15082002
          render json: { "eXpresso" => { "code" => 200, "message" => "Up to date" } }
        else
          render json: { "eXpresso" => { "code" => 207, "message" => "Update required" } }
        end
      end

      def check_ios_version
        if params[:version].to_i >= 15081901
          render json: { "eXpresso" => { "code" => 1, "message" => "Up to date" } }
        else
          render json: { "eXpresso" => { "code" => -207, "message" => "Update required" } }
        end
      end

    end
  end
end
