include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class InvitationsController < ApplicationController

      before_filter :restrict_access, :set_headers
      before_filter :fetch_invitation, :except => [:verify_cell_number, :re_verify_cell_number, :send_invitation_code_via_number]

      respond_to :json

      def fetch_invitation
        if Invitation.exists?(:id => params[:id])
          @invitation = Invitation.find_by_id(params[:id])
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
          #:to => "+"+number,
          :to => number.size > 10 ? "+"+ number : number,
          :from => "+16137028842"
        )
        if message
          return 1
        else
          return 2
        end
      end

      def complete_signup
        if Location.exists?(:four_sq_id => params[:LocationUniqueID])
          @location = Location.where(:four_sq_id => params[:LocationUniqueID]).first
          @user = User.create_new_user(params, @location[:id])
        elsif Location.exists?(:google_map_id => params[:LocationUniqueID])
          @location = Location.where(:google_map_id => params[:LocationUniqueID]).first
          @user = User.create_new_user(params, @location[:id])
        else
          @location = Location.create_new_location(params)
          if @location
            @user = User.create_new_user(params, @location[:id])
          end
        end

        if @location && @user
          if @user[:system_user]
            if UserPrivilege.exists?(:location_id => @location[:id], :owner_id => params[:user_id])
              @privilege = UserPrivilege.where(:location_id => @location[:id], :owner_id => params[:user_id]).first
              @privilege.update_attributes(:is_approved => true, :is_admin => false, :read_only => false, :is_root => false, :is_system => false, :is_coffee => true, :is_invisible => true, :is_valid => true)
              @privilege.setup_coffee_admin_subscriptions(@location)
            else
              # Brand new user
              @privilege = UserPrivilege.new(:org_id => 1,
                :location_id => @location[:id],
                :owner_id => @user[:id],
                :is_approved => true,
                :is_coffee => true,
                :is_invisible => true,
                :is_admin => false,
                :is_root => false,
                :is_valid => true
              )
              if @privilege.save
                @privilege.setup_coffee_admin_subscriptions(@location)
                render json: { "eXpresso" => { "code" => 1 } }
              else
                render json: { "eXpresso" => { "code" => -1, "error" => "Problem setting up subscriptions" } }
              end
            end
          else
            if @location[:require_approval]
              @privilege = UserPrivilege.new(:org_id => 1,
                :location_id => @location[:id],
                :owner_id => @user[:id],
                :is_approved => false,
                :is_admin => false,
                :is_root => false,
                :is_valid => true
              )
              if @privilege.save
                @privilege.setup_location_subscriptions(@location, false, @user)
                render json: { "eXpresso" => { "code" => 1 } }
              else
                render json: { "eXpresso" => { "code" => -1, "error" => "Problem setting up subscriptions" } }
              end
            else
              @privilege = UserPrivilege.new(:org_id => 1,
                :location_id => @location[:id],
                :owner_id => @user[:id],
                :is_approved => true,
                :is_admin => false,
                :is_root => false,
                :is_valid => true
              )
              if @privilege.save
                @privilege.setup_location_subscriptions(@location, true, @user)
                render json: { "eXpresso" => { "code" => 1 } }
              else
                render json: { "eXpresso" => { "code" => -1, "error" => "Problem setting up subscriptions" } }
              end
            end
          end
        else
          render json: { "eXpresso" => { "code" => -1, "error" => "Problem setting up the user or location" } }
        end
      end
    end
  end
end
