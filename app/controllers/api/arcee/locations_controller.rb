include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class LocationsController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      #before_filter :validate_session, :except => [:join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password]
      before_filter :fetch_location, :except => [:create]

      respond_to :json
      
      def fetch_location
        if Location.exists?(:id => params[:id])
          @location = Location.find_by_id(params[:id])
        end
      end

      def create
        @location = Location.new(params[:location])
        
        if @location.save
          render json: @location, serializer: LocationDashboardSerializer
        else
          render json: { "eXpresso" => { "code" => -122, "message" => "Create error" } }
        end
      end

      def update
        if @location.update(params[:location])
          #render json: @location, serializer: LocationSerializer
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -123, "message" => "Create error" } }
        end
      end

      def destroy
        if @location.destroy_this
          render json: { "eXpresso" => { "code" => 1, "message" => "Success", "obj_id" => @location[:id] } }
        else
          render json: { "eXpresso" => { "code" => -124, "message" => "Create error" } }
        end
      end      
    end
  end
end