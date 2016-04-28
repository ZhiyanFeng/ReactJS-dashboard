include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
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

      def update_push_id
        if Mession.exists?(:id => params[:id], :is_valid => true)
          @mession = Mession.find(params[:id])
          @mession.update_attribute(:push_id, params[:push_id])
          render json: { "eXpresso" => { "code" => 1, "message" => "Success", "error" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Something went wrong.", "error" => "Mession with ID: #{params[:id]} is invalid or has expired." } }
        end
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

      def sms_login_send
        if params[:phone_number].present?
          phone_number = params[:phone_number].gsub(/\W/,'')
          if User.exists?(["phone_number like ?", "%#{phone_number}%"])
            @user = User.where("phone_number = ? AND is_valid", phone_number).first
            code = 999 + Random.rand(10000 - 1000)
            send_sms_login_code(code, @user[:phone_number])
            @sms = SmsLogin.create(
              :user_id => @user[:id],
              :validation_code => code,
              :validation_entered => "",
              :is_used => false,
              :is_valid => true
            )
            render json: { "eXpresso" => { "code" => 1, "message" => "Success", "response" => code, "response_id" => @sms[:id]  } }
          else
            render json: { "eXpresso" => { "code" => -1, "message" => "Could not send the login code" } }
          end
        end
      end

      def sms_login_validate
        if params[:phone_number].present?

        end
      end

      def create
        if params[:phone_number].present?
          #phone_number = params[:phone_number].gsub(/[\+\-\(\)\s]/,'')
          phone_number = params[:phone_number].gsub(/\W/,'')
          @user = User.where("phone_number = ? AND is_valid", phone_number).first
        elsif
          @user = User.where("lower(email) = ? AND is_valid", params[:email].downcase).first
        else
          @user = false
        end
        #if @user = User.find(:first, :conditions => ["lower(email) = ? AND is_valid", params[:email].downcase] )
        if @user
          if ["075A60BC-D5ED-4390-BF6A-C3745F70BAC7"].include?(params[:mession][:device_id])
            Mession.clean_via_device(params[:mession][:device_id])

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
          elsif Mession.exists?(:id => params[:session_id], :user_id => @user[:id], :is_valid => true, :is_active => true)
            @mession = Mession.where(:id => params[:session_id], :user_id => @user[:id], :is_valid => true, :is_active => true).last

            status = @user.authenticate_location_based(params[:password])
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
              UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
              render json: @mession, serializer: MessionSuccessSerializer
            else
              render json: { "eXpresso" => { "code" => 401, "message" => "Invalid password" } }
            end
          elsif @user[:system_user]
            Mession.clean(@user[:id], params[:mession][:push_id], params[:mession][:device_id])

            status = @user.authenticate_location_based(params[:password])
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
                UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
                render json: @mession, serializer: MessionSuccessSerializer
              else
                render json: @mession, serializer: Mession210Serializer
              end
            else
              render json: { "eXpresso" => { "code" => 404, "message" => "Unknown error" } }
            end

            #@mession = Mession.new(
            #  :user_id => @user[:id],
            #  :org_id => @user[:active_org],
            #  :device => params[:mession][:device],
            #  :device_id => params[:mession][:device_id],
            #  :push_to => params[:mession][:push_to],
            #  :push_id => params[:mession][:push_id]
            #)
            #@mession.save

            #render json: @mession, serializer: MessionSuccessSerializer
          else
            # mession has became inactive, see if a new one can be created
            Mession.clean(@user[:id], params[:mession][:push_id], params[:mession][:device_id])
            status = @user.authenticate_location_based(params[:password])
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
                UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
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
          render json: { "eXpresso" => { "code" => 1, "message" => "Up to date" } }
        else
          render json: { "eXpresso" => { "code" => -207, "title" => "Thank you for using Coffee Mobile", "message" => "Hey there, we've recently added some important features that require an app update. Please press OK to continue." } }
        end
      end

      def check_ios_version
        if params[:version].to_i >= 15081901
          render json: { "eXpresso" => { "code" => 1, "message" => "Up to date" } }
        else
          render json: { "eXpresso" => { "code" => -207, "message" => "Update required" } }
        end
      end

      private

      def send_sms_login_code(code, phone_number)
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token
        begin
          message = @client.account.messages.create(
            :body => "Your Shyft login code is #{code}. Please enter it now. Email hello@myshyft.com for assitance.",
            :to => phone_number.size > 10 ? "+"+ phone_number : phone_number,
            :from => "+16282225566"
          )
        rescue Twilio::REST::RequestError => e
          ErrorLog.create(
            :file => "messions_controller.rb",
            :function => "send_sms_login_code",
            :error => "Error #{e} on line #{__LINE__}")
        end
      end

    end
  end
end
