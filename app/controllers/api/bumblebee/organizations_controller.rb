include ActionController::HttpAuthentication::Token::ControllerMethods
include ApplicationHelper

module Api
  module Bumblebee
    class OrganizationsController < ApplicationController
      class Organization < ::Organization
        # Note: this does not take into consideration the create/update actions for changing released_on
        
        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:web_create]
      before_filter :fetch_org, :except => [:index, :list, :list_applicants]
      
      respond_to json:

      def fetch_org
        if Organization.exists?(:id => params[:id])
          @organization = Organization.find_by_id(params[:id])
        end
      end

      def seek
        if @organization = Organization.where("lower(name) LIKE lower(:prefix) AND is_valid", prefix: "%#{params[:data]}%").limit(15)
        #if @organization = Organization.where("lower(name) like '%?%'", params[:data].downcase).limit(15)
          render json: @organization, each_serializer: OrganizationSerializer
          #render json: { "eXpresso" => { "code" => 1, "payload" => OrganizationSeekSerializer.new(@organization.first) } }
        else
          render json: { "eXpresso" => { "code" => -104, "message" => @organization.errors } }
        end
      end
      
      def index
        @organizations = Organization.all
        render json: @organizations, each_serializer: OrganizationSerializer
      end
      
      #def list
      #  @organizations = Organization.all
      #  @privileges = UserPrivilege.all(
      #    :conditions => {
      #      :owner => params[:id],
      #      :is_valid => true
      #    }
      #  )
      #  render json: @organizations, each_serializer: OrganizationSerializer
      #end

      def show
        render json: @organization, serializer: OrganizationSerializer
      end
      
      def web_create
        #response = User.setup_new_org(params)

        #if response == 1
        #  redirect_to registered_url
        #elsif response == -1
        #  redirect_to signup_url(:email => params[:user][:email], :first_name => params[:user][:first_name], :last_name => params[:user][:last_name], :code => -203), :notice => "Email address already exist"
        #elsif response == -2
        #  render json: { "eXpresso" => { "code" => -202, "message" => "Could not complete the organization setup." } }
        #else 
        #  render json: { "eXpresso" => { "code" => -203, "message" => "Could not complete the setup for unknown reason." } }
        #end
        response = Organization.setup_new_org("web",params)
        if response == "!Organization"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!User"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!OrganizationProfile"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!UserNotificationCounter"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!UserPrivilege"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!Post"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!Location"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        else
          redirect_to registered_url
        end
      end

      #def create2
      #  response = Organization.setup_new_org(params)
      #end

      def create
        response = Organization.setup_new_org("app",params)
        if response == "!Organization"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!User"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!OrganizationProfile"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!UserNotificationCounter"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!UserPrivilege"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!Post"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        elsif response == "!Location"
          render json: { "eXpresso" => { "code" => -203, "message" => response } }
        else
          render json: response, serializer: UserPrivilegeSerializer
        end
      end
      
      def update
        @organization.update_attribute(:profile_id, params[:profile_id]) if params[:profile_id].presence
        render :json => @user, serializer: UserProfileSerializer
      end
      
      def destroy
        if @organization.update(:is_valid => false)
          render json: @organization, serializer: OrganizationSerializer
        else
          render json: @organization.errors
        end
      end
      
      #def list_applicants
      #  @keys = AccessKey.all(
      #    :include => [:users],
      #    :conditions => {
      #      :org_id => params[:id],
      #      :is_approved => false
      #    }
      #  )
      #  render json: @users, each_serializer: UserSerializer
      #end

      def get_organization_groups
        render json: @organization, serializer: OrganizationGroupSerializer
      end
      
      def is_valid
        render json: @organization.is_valid
      end
      
      def profile
        if @organization.gallery_image.presence
          @organization.gallery_image.each do |p|
            p.check_user(params[:id])
          end
        end
        
        if @organization.profile_image.presence
          @organization.profile_image.check_user(params[:id])
        end

        render json: @organization, serializer: OrganizationProfileSerializer
      end

      def gallery
        @gallery = Image.where(
          :org_id => params[:id],
          :image_type => [1,3]
        )
        
        @gallery.each do |p|
          p.check_user(params[:user_id])
        end
        
        render json: @gallery, each_serializer: ImageSerializer
      end
      
      def fetch_org_data
        users = {}
        posts = {}
        messages = {}
        likes = {}
        users["total"] = 0
        posts["total"] = 0
        messages["total"] = 0
        likes["total"] = 0
        
        user_list = User.where(:active_org => params[:id]).pluck(:id)
        
        query = "SELECT d.date, count(se.id) FROM (
            select to_char(date_trunc('day', (current_date - offs)), 'YYYY-MM-DD')
            AS date 
            FROM generate_series(0, 365, 1) 
            AS offs
            ) d 
        LEFT OUTER JOIN posts se 
        ON (d.date=to_char(date_trunc('day', se.created_at), 'YYYY-MM-DD'))  
        WHERE org_id = #{params[:id]} GROUP BY d.date ORDER BY d.date DESC;"
        post_data = ActiveRecord::Base.connection.execute(query)
        post_data.each do |p|
          posts[p["date"]] = p["count"].to_i
          posts["total"] = posts["total"] + p["count"].to_i
        end
        
        query = "SELECT d.date, count(se.id) FROM (
            select to_char(date_trunc('day', (current_date - offs)), 'YYYY-MM-DD')
            AS date 
            FROM generate_series(0, 365, 1) 
            AS offs
            ) d 
        LEFT OUTER JOIN chat_messages se 
        ON (d.date=to_char(date_trunc('day', se.created_at), 'YYYY-MM-DD'))  
        WHERE sender_id IN (#{user_list.join(", ")}) GROUP BY d.date ORDER BY d.date DESC;"
        chat_data = ActiveRecord::Base.connection.execute(query)
        chat_data.each do |p|
          messages[p["date"]] = p["count"].to_i
          messages["total"] = messages["total"] + p["count"].to_i
        end
        
        query = "SELECT d.date, count(se.id) FROM (
            select to_char(date_trunc('day', (current_date - offs)), 'YYYY-MM-DD')
            AS date 
            FROM generate_series(0, 365, 1) 
            AS offs
            ) d 
        LEFT OUTER JOIN likes se 
        ON (d.date=to_char(date_trunc('day', se.created_at), 'YYYY-MM-DD'))  
        WHERE owner_id in (#{user_list.join(", ")}) GROUP BY d.date ORDER BY d.date DESC;"
        like_data = ActiveRecord::Base.connection.execute(query)
        like_data.each do |p|
          likes[p["date"]] = p["count"].to_i
          likes["total"] = likes["total"] + p["count"].to_i
        end
        
        query = "SELECT d.date, count(DISTINCT se.user_id) FROM (
            select to_char(date_trunc('day', (current_date - offs)), 'YYYY-MM-DD')
            AS date 
            FROM generate_series(0, 365, 1) 
            AS offs
            ) d 
        LEFT OUTER JOIN messions se 
        ON (d.date=to_char(date_trunc('day', se.created_at), 'YYYY-MM-DD'))  
        WHERE org_id = #{params[:id]} GROUP BY d.date ORDER BY d.date DESC;"
        user_data = ActiveRecord::Base.connection.execute(query)
        user_data.each do |p|
          users[p["date"]] = p["count"].to_i
          users["total"] = users["total"] + p["count"].to_i
        end
        
        result = {}
        result["users"] = users
        result["posts"] = posts
        result["messages"] = messages
        result["likes"] = likes

        result
        ActiveRecord::Base.connection.close

        render json: result.to_json
      end

      private

      def restrict_access
        #X-Method: cc5f43ea7132996963e9a62fabde3c6f
        #Authorization: Token token="cc5f43ea7132996963e9a62fabde3c6f", nonce="def"
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

    end
  end
end
