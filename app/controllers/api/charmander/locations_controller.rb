include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Charmander
    class LocationsController < ApplicationController

      before_filter :restrict_access, :set_headers
      #before_filter :validate_session, :except => [:join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password]
      before_filter :fetch_location, :except => [:create]

      respond_to :json

      def fix_location_coordinates
        count = 0
        Location.where("(lng IS NOT NULL AND lng != '') AND (lat IS NOT NULL AND lat != '') AND is_valid").each do |location|
          location.update_attributes(:latitude => location.lat, :longitude => location.lng)
          count = count  + 1
        end
        render json: { "eXpresso" => { "code" => 1, "message" => "#{count} locations fixed" } }
      end

      def fetch_location
        #if Location.exists?(:id => params[:id])
        if Location.exists?(:four_sq_id => params[:LocationUniqueID])
          #@location = Location.find_by_id(params[:id])
          @location = Location.where(:four_sq_id => params[:LocationUniqueID]).first
        elsif Location.exists?(:google_map_id => params[:LocationUniqueID])
          @location = Location.where(:google_map_id => params[:LocationUniqueID]).first
        else
          @location = Location.new(
            :org_id => 1,
            :owner_id => 134,
            :location_name => params[:LocationName],
            :address => params[:Address],
            :city => params[:City],
            :province => params[:Province],
            :country => params[:Country],
            :postal => params[:Postal],
            :formatted_address => params[:FormattedAddress],
            :is_hq => false,
            :lng => params[:Lng],
            :lat => params[:Lat],
            :category => params[:category]
          )
          if @location.save!
            #SETUP THE DATA SOURCE OF THE LOCATION
            if params[:LocationSource] == "FourSquare"
              @location.update_attribute(:four_sq_id, params[:LocationUniqueID])
            elsif params[:LocationSource] == "GoogleMap"
              @location.update_attribute(:google_map_id, params[:LocationUniqueID])
            else
            end
            # END
            #SETUP THE ADMIN USER TO MANAGE THE LOCATION
            AdminPrivilege.grant_location_access(134, @location[:id])
            # END
          end
        end
      end

      def join_location
        if @location
          if User.exists?(:id => params[:user_id])
            @user = User.find(params[:user_id])
            @user.update_attributes(:shyft_score => @user[:shyft_score] + 3)
            if @user[:system_user]
              if UserPrivilege.exists?(:location_id => @location[:id], :owner_id => params[:user_id])
                @privilege = UserPrivilege.where(:location_id => @location[:id], :owner_id => params[:user_id]).first
                @privilege.update_attributes(:is_approved => true, :is_admin => false, :read_only => false, :is_root => false, :is_system => false, :is_coffee => true, :is_invisible => true, :is_valid => true)
                if @privilege.setup_coffee_admin_subscriptions(@location)
                  render json: { "eXpresso" => { "code" => 1 } }
                else
                  render json: { "eXpresso" => { "code" => -1, "error" => "Problem setting up subscriptions" } }
                end
              else
                # Brand new user
                @privilege = UserPrivilege.new(:org_id => 1,
                  :location_id => @location[:id],
                  :owner_id => params[:user_id],
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
              if UserPrivilege.exists?(:location_id => @location[:id], :owner_id => params[:user_id])
                @privilege = UserPrivilege.where(:location_id => @location[:id], :owner_id => params[:user_id]).first
                if @privilege[:is_valid] == true
                  # User already in the location
                  @privilege.setup_location_subscriptions(@location, true, @user)
                  render json: { "eXpresso" => { "code" => -1, "error" => "User already in the location with id #{params[:id]}" } }
                elsif @privilege[:is_valid] == false
                  # User was previously in the location, make current key active again
                  if @location[:require_approval]
                    # Location require approval
                    @privilege.update_attributes(:is_approved => false, :is_admin => false, :read_only => false, :is_root => false, :is_system => false, :is_valid => true)
                    #@user.update_attribute(:access_key_count, @user[:access_key_count] + 1)
                    @privilege.setup_location_subscriptions(@location, false, @user)
                    render json: { "eXpresso" => { "code" => 1 } }
                  else
                    # Location does not require approval
                    @privilege.update_attributes(:is_approved => true, :is_admin => false, :read_only => false, :is_root => false, :is_system => false, :is_valid => true)
                    #@user.update_attribute(:access_key_count, @user[:access_key_count] + 1)
                    @privilege.setup_location_subscriptions(@location, true, @user)
                    render json: { "eXpresso" => { "code" => 1 } }
                  end
                else
                  # Something Strange, should not hit here
                end
              else
                # Brand new user
                if @location[:require_approval]
                  @privilege = UserPrivilege.new(:org_id => 1,
                    :location_id => @location[:id],
                    :owner_id => params[:user_id],
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
                    :owner_id => params[:user_id],
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
            end
          else
            render json: { "eXpresso" => { "code" => -1, "error" => "Could not find user with the id #{params[:user_id]}" } }
          end
        else
          render json: { "eXpresso" => { "code" => -1, "error" => "Could not find channel with the id #{params[:id]}" } }
        end
      end

    end
  end
end
