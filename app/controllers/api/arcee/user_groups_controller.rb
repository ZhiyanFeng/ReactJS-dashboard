include ActionController::HttpAuthentication::Token::ControllerMethods

module Api
  module Arcee
    class UserGroupsController < ApplicationController
      
      before_filter :restrict_access, :set_headers
      #before_filter :validate_session, :except => [:join_org, :create, :select_org, :validate_user, :update, :set_admin, :remove_admin, :reset_password]
      before_filter :fetch_group, :except => [:create]

      respond_to :json

      def fetch_group
        if UserGroup.exists?(:id => params[:id])
          @group = UserGroup.find_by_id(params[:id])
        end
      end

      def create
        @group = UserGroup.new(params[:group])
        
        if @group.save
          render json: @group, serializer: UserGroupSerializer
        else
          render json: { "eXpresso" => { "code" => -122, "message" => "Create error" } }
        end
      end

      def update
        if @group.update(params[:group])
          render json: @group, serializer: UserGroupSerializer
          #render json: { "eXpresso" => { "code" => 200, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -123, "message" => "Create error" } }
        end
      end

      def setup_user_groups
        User.all.each do |user|
          if !UserGroupMapping.exists?(:user_id => user[:id], :org_id => user[:active_org], :group_id => user[:user_group])
            if user[:active_org].present? && user[:user_group].present? && user[:user_group].to_i != 0
              UserGroupMapping.create(:user_id => user[:id], :org_id => user[:active_org], :group_id => user[:user_group])
            end
          end
        end
      end

      def destroy
        if @group.destroy_this
          render json: { "eXpresso" => { "code" => 200, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -123, "message" => "Create error" } }
        end
      end      
    end
  end
end