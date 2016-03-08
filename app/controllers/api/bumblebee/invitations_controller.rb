include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Bumblebee
    class InvitationsController < ApplicationController

      before_filter :restrict_access, :set_headers
      before_filter :fetch_invitation, :except => [:send_invite, :verify_email, :re_verify_email, :finish_signup, :verify_cell_number, :re_verify_cell_number, :send_invitation_code_via_number]

      respond_to :json

      def fetch_invitation
        if Invitation.exists?(:id => params[:id])
          @invitation = Invitation.find_by_id(params[:id])
        end
      end

      def send_invite
        if Invitation.exists?(:email => params[:email])
          render json: { "eXpresso" => { "code" => -100, "message" => "Email already invited" } }
        elsif User.exists?(:email => params[:email])
          render json: { "eXpresso" => { "code" => -101, "message" => "Email already registered" } }
        else
          if @invitation = Invitation.create(:email => params[:email])
            begin
              NotificationsMailer.invitation(@invitation).deliver
            rescue
            end
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code] } }
          else
            render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
          end
        end
      end

      def verify_email
        if User.exists?(:email => params[:email])
          render json: { "eXpresso" => { "code" => -101, "message" => "Email already registered" } }
        elsif Invitation.exists?(:email => params[:email].downcase, :is_valid => true)
          @invitation = Invitation.where(:email => params[:email].downcase, :is_valid => true).first
          if @invitation[:is_invited]
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          elsif @invitation[:is_whitelisted]
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          else
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          end
          NotificationsMailer.send_invitation_code(@invitation).deliver
        else
          if @whitelist = WhitelistedDomain.where("lower(domain) = ?", params[:email].split("@")[1]).first
            if @invitation = Invitation.create(:email => params[:email], :org_id => @whitelist[:org_id], :is_whitelisted => true)
              render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
              begin
                NotificationsMailer.send_invitation_code(@invitation).deliver
              rescue
              end
            else
              render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
            end
          else
            if @invitation = Invitation.create(:email => params[:email])
              render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
              begin
                NotificationsMailer.send_invitation_code(@invitation).deliver
              rescue
              end
            else
              render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
            end
          end
        end
      end

      def re_verify_email
        if @invitation = Invitation.where(:email => params[:email]).first
          begin
            NotificationsMailer.send_invitation_code(@invitation).deliver
          rescue
          end
          render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code] } }
        else
          render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
        end
      end

      def verify_cell_number
        phone_number = params[:phone_number].gsub(/[\+\-\(\)\s]/,'')
        if User.exists?(:phone_number => phone_number)
          render json: { "eXpresso" => { "code" => -101, "message" => "Phone number already registered" } }
        elsif Invitation.exists?(:phone_number => phone_number, :is_valid => true)
          @invitation = Invitation.where(:phone_number => phone_number, :is_valid => true).first
          if @invitation[:is_invited]
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          elsif @invitation[:is_whitelisted]
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          else
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
          end
          self.send_invitation_code_via_number(@invitation[:invite_code], params[:phone_number])
        else
          if @invitation = Invitation.create(:phone_number => phone_number)
            if self.send_invitation_code_via_number(@invitation[:invite_code], params[:phone_number])
              render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code], "invitation" => InvitationVerifySerializer.new(@invitation) } }
            else
              render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
            end
          else
            render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
          end
        end
      end

      def re_verify_cell_number
        if @invitation = Invitation.where(:phone_number => params[:phone_number]).first
          if self.send_invitation_code_via_number(@invitation[:invite_code], params[:phone_number])
            render json: { "eXpresso" => { "code" => 1, "message" => @invitation[:invite_code] } }
          else
            render json: { "eXpresso" => { "code" => -102, "message" => @invitation.errors } }
          end
        end
      end

      def send_invitation_code_via_number(code, number)
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token

        message = @client.account.messages.create(
          :body => "#{code} is your Shyft verification code, please enter it within the next 30 mins.",
          :to => "+" + number,
          :from => "+16137028842"
        )
        if message
          return 1
        else
          return 2
        end
      end

      def complete_signup
        if @invitation = Invitation.find(params[:id])
          result = @invitation.setup_user(params)
          #if @invitation.setup_user(params)
          if result
            if params[:Email].present?
              setup_email = params[:Email]
            else
              setup_email = params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,'') + "@coffeemobile.com"
            end
            @user = User.where(['email = ? OR phone_number = ?', setup_email, @invitation[:phone_number]]).first
            #@user = User.where(:email => @invitation[:email]).first
            render json: { "eXpresso" => { "code" => 1, "message" => "success", "user" => UserProfileSerializer.new(@user) } }
          else
            render json: { "eXpresso" => { "code" => -106, "message" => "failed" } }
          end
        else
          render json: { "eXpresso" => { "code" => -107, "message" => @invitation.errors } }
        end
      end

      def finish_signup
        #@image.create_and_upload_user_cover_image(params[:owner_id], params[:file])
        #@image.create_upload_and_set_user_profile(params[:owner_id], params[:file])
        if @invitation = Invitation.find(params[:id])
          if @invitation[:is_invited]
            if @invitation.setup_new_users(params) > 0
              @user = User.where(:email => @invitation[:email]).first
              render json: { "eXpresso" => { "code" => 1, "message" => "success", "user" => UserProfileSerializer.new(@user) } }
            else
              render json: { "eXpresso" => { "code" => -104, "message" => "failed" } }
            end
          elsif @invitation[:is_whitelisted]
            if @invitation.setup_whitelisted_users(params) > 0
              @user = User.where(:email => @invitation[:email]).first
              render json: { "eXpresso" => { "code" => 1, "message" => "success", "user" => UserProfileSerializer.new(@user) } }
            else
              render json: { "eXpresso" => { "code" => -105, "message" => "failed" } }
            end
          else
            response = @invitation.setup_new_users(params)
            if response > 0
              @user = User.where(:email => @invitation[:email]).first
              render json: { "eXpresso" => { "code" => 1, "message" => "success", "user" => UserProfileSerializer.new(@user) } }
            else
              render json: { "eXpresso" => { "code" => -106, "message" => "failed" } }
            end
          end
        else
          render json: { "eXpresso" => { "code" => -107, "message" => @invitation.errors } }
        end
      end

    end
  end
end
