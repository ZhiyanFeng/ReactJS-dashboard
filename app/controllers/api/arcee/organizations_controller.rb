include ActionController::HttpAuthentication::Token::ControllerMethods
include ApplicationHelper

module Api
  module Arcee
    class OrganizationsController < ApplicationController
      class Organization < ::Organization
        # Note: this does not take into consideration the create/update actions for changing released_on

        # Sub class to override column name in response
        #def as_json(options = {})
        #  super.merge(released_on: created_at.to_date)
        #end
      end

      before_filter :restrict_access, :set_headers, :except => [:web_create, :get_dashboard_settings_info, :get_dashboard_select_info]
      before_filter :fetch_org, :except => [:index, :list, :list_applicants, :fetch_quizzes, :seek]

      respond_to json:

      def fetch_org
        if Organization.exists?(:id => params[:id])
          @organization = Organization.find_by_id(params[:id])
        end
      end

      def seek
        #if @organization = Organization.where("name LIKE :prefix", prefix: "#{params[:data]}%").first
        #if @organization = Organization.where("lower(name) = ?", params[:data].downcase)
        @organization = Organization.where("lower(name) = lower(?)", params[:data])
        if !@organization.first.present?
          @organization = Organization.where("lower(name) LIKE lower(:prefix) AND is_valid", prefix: "%#{params[:data]}%").limit(1)
        end
        if @organization.present?
          render json: { "eXpresso" => { "code" => 1, "payload" => OrganizationSeekSerializer.new(@organization.first) } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Query produced empty result." } }
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

      def enable_safety_course
        if Post.exists?(:org_id => params[:post][:org_id], :attachment_id => params[:attachment_id])
          @post = Post.where(:org_id => params[:post][:org_id], :attachment_id => params[:attachment_id]).first
          @post.update_attribute(:is_valid, true);
        else
          @post = Post.new(params[:post])
          if @post.save
            @post.update_attribute(:attachment_id, params[:attachment_id]) if params[:attachment_id].present?
          end
        end
        render json: @post, serializer: PostSerializer
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
        #@keys = AccessKey.all(
        #  :include => [:users],
        #  :conditions => {
        #    :org_id => params[:id],
        #    :is_approved => false
        #  }
        #)
        #render json: @users, each_serializer: UserSerializer
      #end

      def approve_applicants
        @key = UserPrivilege.where(:owner_id => @params[:user_id], :org_id => params[:id]).first
        if @key.approve

        else

        end
      end

      def reject_applicants
        @key = UserPrivilege.where(:owner_id => @params[:user_id], :org_id => params[:id]).first
        if @key.reject

        else

        end
      end

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

      def fetch_quizzes
        posts = Post.where("org_id = 1 AND post_type IN (?) AND is_valid",

          PostType.reference_by_base_type("quiz")
        ).order("posts.updated_at asc")

        render :json => posts, each_serializer: QuizzesSerializer
      end

      def fetch_post_graph_data
        result = {}
        result["total"] = 0
        query = ""

        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])

        diff = (end_date - start_date).to_i

        if diff <= 3
          #query = "SELECT date, coalesce(count,0) AS count FROM generate_series(current_date - 72 * '1 hour'::interval, current_date, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} GROUP BY day) results ON (date = results.day);"
          query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date}'::TIMESTAMP WITH TIME ZONE, '#{end_date}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} GROUP BY day) results ON (date = results.day);"
        elsif diff <= 90
          #query = "SELECT date, coalesce(count,0) AS count FROM generate_series(current_date - 90 * '1 day'::interval, current_date, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} GROUP BY day) results ON (date = results.day);"
          query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date}'::TIMESTAMP WITH TIME ZONE, '#{end_date}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} GROUP BY day) results ON (date = results.day);"
        else
          #query = "SELECT date, coalesce(count,0) AS count FROM generate_series(current_date - 90 * '1 day'::interval, current_date, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} GROUP BY day) results ON (date = results.day);"
        end
        post_data = ActiveRecord::Base.connection.execute(query)
        post_data.each do |p|
          result[p["date"]] = p["count"].to_i
          result["total"] = result["total"] + p["count"].to_i
        end

        ActiveRecord::Base.connection.close

        render json: result.to_json
      end

      def fetch_system_data
        users = {}
        posts = {}
        messages = {}
        likes = {}
        comments = {}

        users["total"] = 0
        posts["total"] = 0
        messages["total"] = 0
        likes["total"] = 0
        comments["total"] = 0

        users["daily"] = {}
        posts["daily"] = {}
        messages["daily"] = {}
        likes["daily"] = {}
        comments["daily"] = {}

        users["hourly"] = {}
        posts["hourly"] = {}
        messages["hourly"] = {}
        likes["hourly"] = {}
        comments["hourly"] = {}

        organization = Organization.find(params[:id])

        user_list = User.where(:active_org => params[:id]).pluck(:id)

        user_query = ""
        post_query = ""
        message_query = ""
        like_query = ""

        org_date = organization[:created_at]
        org_age = (DateTime.now.to_i - organization[:created_at].to_i)/24/60/60
        nighty_days_ago = DateTime.now - 90.days
        end_date = DateTime.now

        Rails.logger.debug("org_date: #{org_date}");
        Rails.logger.debug("org_age: #{org_age}");
        Rails.logger.debug("nighty_days_ago: #{nighty_days_ago}");
        Rails.logger.debug("end_date: #{end_date}");

        if org_age < 90
          start_date = org_date
        else
          start_date = nighty_days_ago
        end

        user_hourly_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.created_at as createdat from messions UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.is_valid = 't' UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.is_valid = 't' UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        post_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', posts.created_at) as day, count(posts.id) as count FROM posts WHERE is_valid='t' AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        message_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages GROUP BY day) results ON (date = results.day);"
        like_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', likes.created_at) as day, count(likes.id) as count FROM likes WHERE is_valid = 't' GROUP BY day) results ON (date = results.day);"
        comment_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', comments.created_at) as day, count(comments.id) as count FROM comments WHERE is_valid='t' GROUP BY day) results ON (date = results.day);"


        user_daily_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.updated_at as createdat from messions UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.is_valid = 't' UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.is_valid = 't' UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        #user_daily_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.created_at as createdat from messions UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.is_valid = 't' UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.is_valid = 't' UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        post_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE is_valid='t' AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        message_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages GROUP BY day) results ON (date = results.day);"
        like_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', likes.created_at) as day, count(likes.id) as count FROM likes WHERE is_valid = 't' GROUP BY day) results ON (date = results.day);"
        comment_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', comments.created_at) as day, count(comments.id) as count FROM comments WHERE is_valid = 't' GROUP BY day) results ON (date = results.day);"


        post_data = ActiveRecord::Base.connection.execute(post_daily_query)
        post_data.each do |p|
          posts["daily"][p["date"]] = p["count"].to_i
          posts["total"] = posts["total"] + p["count"].to_i
        end
        post_hourly_data = ActiveRecord::Base.connection.execute(post_hourly_query)
        post_hourly_data.each do |p|
          posts["hourly"][p["date"]] = p["count"].to_i
        end

        chat_data = ActiveRecord::Base.connection.execute(message_daily_query)
        chat_data.each do |p|
          messages["daily"][p["date"]] = p["count"].to_i
          messages["total"] = messages["total"] + p["count"].to_i
        end
        chat_hourly_data = ActiveRecord::Base.connection.execute(message_hourly_query)
        chat_hourly_data.each do |p|
          messages["hourly"][p["date"]] = p["count"].to_i
        end

        like_data = ActiveRecord::Base.connection.execute(like_daily_query)
        like_data.each do |p|
          likes["daily"][p["date"]] = p["count"].to_i
          likes["total"] = likes["total"] + p["count"].to_i
        end
        like_hourly_data = ActiveRecord::Base.connection.execute(like_hourly_query)
        like_hourly_data.each do |p|
          likes["hourly"][p["date"]] = p["count"].to_i
        end

        comment_data = ActiveRecord::Base.connection.execute(comment_daily_query)
        comment_data.each do |p|
          comments["daily"][p["date"]] = p["count"].to_i
          comments["total"] = comments["total"] + p["count"].to_i
        end
        comment_hourly_data = ActiveRecord::Base.connection.execute(comment_hourly_query)
        comment_hourly_data.each do |p|
          comments["hourly"][p["date"]] = p["count"].to_i
        end

        user_data = ActiveRecord::Base.connection.execute(user_daily_query)
        user_data.each do |p|
          users["daily"][p["date"]] = p["count"].to_i
          users["total"] = users["total"] + p["count"].to_i
        end
        user_hourly_data = ActiveRecord::Base.connection.execute(user_hourly_query)
        user_hourly_data.each do |p|
          users["hourly"][p["date"]] = p["count"].to_i
        end

        result = {}
        result["users"] = users
        result["posts"] = posts
        result["messages"] = messages
        result["likes"] = likes
        result["comments"] = comments

        #result
        ActiveRecord::Base.connection.close

        render json: result.to_json
      end

      def fetch_org_data
        users = {}
        posts = {}
        messages = {}
        likes = {}
        comments = {}

        users["total"] = 0
        posts["total"] = 0
        messages["total"] = 0
        likes["total"] = 0
        comments["total"] = 0

        users["daily"] = {}
        posts["daily"] = {}
        messages["daily"] = {}
        likes["daily"] = {}
        comments["daily"] = {}

        users["hourly"] = {}
        posts["hourly"] = {}
        messages["hourly"] = {}
        likes["hourly"] = {}
        comments["hourly"] = {}

        organization = Organization.find(params[:id])

        user_list = User.where(:active_org => params[:id]).pluck(:id)

        user_query = ""
        post_query = ""
        message_query = ""
        like_query = ""

        #org_date = organization[:created_at]
        #org_age = (DateTime.now.to_i - organization[:created_at].to_i)/24/60/60
        #nighty_days_ago = DateTime.now - 90.days
        #end_date = DateTime.now

        #if org_age < 90
        #  start_date = org_date
        #else
        #  start_date = nighty_days_ago
        #end

        #zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
        #start_date = organization[:created_at].in_time_zone(zone)
        #end_date = params[:end_date].to_date.in_time_zone(zone)

        #user_hourly_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.updated_at as createdat from messions where messions.org_id = #{params[:id]} UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.org_id = #{params[:id]} UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.owner_id in (#{user_list.join(", ")}) UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages where chat_messages.sender_id in (#{user_list.join(", ")})) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        #post_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        #message_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages WHERE sender_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        #like_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', likes.created_at) as day, count(likes.id) as count FROM likes WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        #comment_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d %H:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', comments.created_at) as day, count(comments.id) as count FROM comments WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"

        #user_daily_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.updated_at as createdat from messions where messions.org_id = #{params[:id]} UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.org_id = #{params[:id]} UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.owner_id in (#{user_list.join(", ")}) UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages where chat_messages.sender_id in (#{user_list.join(", ")})) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        #post_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        #message_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages WHERE sender_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        #like_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', likes.created_at) as day, count(likes.id) as count FROM likes WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        #comment_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '#{end_date.strftime "%Y-%m-%d 00:00:00"}'::TIMESTAMP WITH TIME ZONE, '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', comments.created_at) as day, count(comments.id) as count FROM comments WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"

        start_date = Time.zone.parse(organization[:created_at].to_s).utc
        end_date = Time.zone.parse(params[:end_date]).utc

        user_hourly_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.updated_at as createdat from messions where messions.org_id = #{params[:id]} UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.org_id = #{params[:id]} UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.owner_id in (#{user_list.join(", ")}) UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages where chat_messages.sender_id in (#{user_list.join(", ")})) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}', '#{end_date.strftime "%Y-%m-%d %H:00:00"}', '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        post_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}', '#{end_date.strftime "%Y-%m-%d %H:00:00"}', '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        message_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}', '#{end_date.strftime "%Y-%m-%d %H:00:00"}', '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages WHERE sender_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        like_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}', '#{end_date.strftime "%Y-%m-%d %H:00:00"}', '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', likes.created_at) as day, count(likes.id) as count FROM likes WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        comment_hourly_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d %H:00:00"}', '#{end_date.strftime "%Y-%m-%d %H:00:00"}', '1 hour'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('hour', comments.created_at) as day, count(comments.id) as count FROM comments WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"

        user_daily_query = "WITH mession_data AS (SELECT messions.user_id as userid, messions.updated_at as createdat from messions where messions.org_id = #{params[:id]} UNION ALL SELECT posts.owner_id as userid, posts.created_at as createdat from posts where posts.org_id = #{params[:id]} UNION ALL SELECT likes.owner_id as userid, likes.created_at as createdat from likes where likes.owner_id in (#{user_list.join(", ")}) UNION ALL SELECT chat_messages.sender_id as userid, chat_messages.created_at as createdat from chat_messages where chat_messages.sender_id in (#{user_list.join(", ")})) SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', mession_data.createdat) as day, count(DISTINCT mession_data.userid) as count FROM mession_data GROUP BY day) results ON (date = results.day);"
        post_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', posts.created_at) as day, count(posts.id) as count FROM posts WHERE org_id = #{params[:id]} AND post_type >= 5 AND post_type <=9 GROUP BY day) results ON (date = results.day);"
        message_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', chat_messages.created_at) as day, count(chat_messages.id) as count FROM chat_messages WHERE sender_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        like_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', likes.created_at) as day, count(likes.id) as count FROM likes WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"
        comment_daily_query = "SELECT date, coalesce(count,0) AS count FROM generate_series('#{start_date.strftime "%Y-%m-%d 00:00:00"}', '#{end_date.strftime "%Y-%m-%d 00:00:00"}', '1 day'::interval) AS date LEFT OUTER JOIN (SELECT date_trunc('day', comments.created_at) as day, count(comments.id) as count FROM comments WHERE owner_id IN (#{user_list.join(", ")}) GROUP BY day) results ON (date = results.day);"

        post_data = ActiveRecord::Base.connection.execute(post_daily_query)
        post_data.each do |p|
          posts["daily"][p["date"]] = p["count"].to_i
          posts["total"] = posts["total"] + p["count"].to_i
        end
        post_hourly_data = ActiveRecord::Base.connection.execute(post_hourly_query)
        post_hourly_data.each do |p|
          posts["hourly"][p["date"]] = p["count"].to_i
        end

        chat_data = ActiveRecord::Base.connection.execute(message_daily_query)
        chat_data.each do |p|
          messages["daily"][p["date"]] = p["count"].to_i
          messages["total"] = messages["total"] + p["count"].to_i
        end
        chat_hourly_data = ActiveRecord::Base.connection.execute(message_hourly_query)
        chat_hourly_data.each do |p|
          messages["hourly"][p["date"]] = p["count"].to_i
        end

        like_data = ActiveRecord::Base.connection.execute(like_daily_query)
        like_data.each do |p|
          likes["daily"][p["date"]] = p["count"].to_i
          likes["total"] = likes["total"] + p["count"].to_i
        end
        like_hourly_data = ActiveRecord::Base.connection.execute(like_hourly_query)
        like_hourly_data.each do |p|
          likes["hourly"][p["date"]] = p["count"].to_i
        end

        comment_data = ActiveRecord::Base.connection.execute(comment_daily_query)
        comment_data.each do |p|
          comments["daily"][p["date"].in_time_zone] = p["count"].to_i
          comments["total"] = comments["total"] + p["count"].to_i
        end
        comment_hourly_data = ActiveRecord::Base.connection.execute(comment_hourly_query)
        comment_hourly_data.each do |p|
          comments["hourly"][p["date"]] = p["count"].to_i
        end

        user_data = ActiveRecord::Base.connection.execute(user_daily_query)
        user_data.each do |p|
          users["daily"][p["date"]] = p["count"].to_i
          users["total"] = users["total"] + p["count"].to_i
        end
        user_hourly_data = ActiveRecord::Base.connection.execute(user_hourly_query)
        user_hourly_data.each do |p|
          users["hourly"][p["date"]] = p["count"].to_i
        end

        result = {}
        result["users"] = users
        result["posts"] = posts
        result["messages"] = messages
        result["likes"] = likes
        result["comments"] = comments

        #result
        ActiveRecord::Base.connection.close

        render json: result.to_json
      end

      def get_dashboard_select_info
        organizations_id = AdminPrivilege.where(:owner_id => current_user[:id]).pluck("DISTINCT org_id")
        @orgs = Organization.where('id IN (?)', organizations_id)

        result = {}
        result["organizations"] = ActiveModel::ArraySerializer.new(@orgs, each_serializer: OrganizationSerializer)
        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_dashboard_announcements_info
        @users = User.where(:active_org => params[:id], :is_valid => true)
        @announcements = Post.where("org_id = ? AND post_type IN (?) AND is_valid AND created_at <= ?",
              params[:id],
              PostType.reference_by_base_type("announcement"),
              Time.now()
            ).order("posts.created_at desc").limit(50)
        @newsfeeds = Post.where("org_id = ? AND post_type IN (?) AND is_valid AND created_at <= ?",
              params[:id],
              PostType.reference_by_base_type("post"),
              Time.now()
            ).order("posts.created_at desc").limit(50)
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at asc')
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        result = {}
        result["users"] = ActiveModel::ArraySerializer.new(@users, each_serializer: UserManagementSerializer)
        result["announcements"] = ActiveModel::ArraySerializer.new(@announcements, each_serializer: AnnouncementManagementSerializer)
        result["newsfeeds"] = ActiveModel::ArraySerializer.new(@newsfeeds, each_serializer: NewsfeedSerializer)
        result["locations"] = ActiveModel::ArraySerializer.new(@locations, each_serializer: LocationDashboardSerializer)
        result["groups"] = ActiveModel::ArraySerializer.new(@groups, each_serializer: UserGroupSerializer)

        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_dashboard_trainings_info
        @users = User.where(:active_org => params[:id], :is_valid => true)
        @trainings = Post.where("org_id = ? AND (post_type IN (?) OR post_type IN (?)) AND is_valid AND created_at <= ?",
              params[:id],
              PostType.reference_by_base_type("training"),
              PostType.reference_by_base_type("safety_training"),
              Time.now()
            ).order("posts.created_at desc").limit(50)
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at asc')
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        @safety_trainings = SafetyCourse.all
        @safety_trainings.each do |p|
          p.check_org(params[:id])
        end

        result = {}
        result["users"] = ActiveModel::ArraySerializer.new(@users, each_serializer: UserManagementSerializer)
        result["trainings"] = ActiveModel::ArraySerializer.new(@trainings, each_serializer: TrainingManagementSerializer)
        result["safety_trainings"] = ActiveModel::ArraySerializer.new(@safety_trainings, each_serializer: DashboardSafetyCourseSerializer)
        result["locations"] = ActiveModel::ArraySerializer.new(@locations, each_serializer: LocationDashboardSerializer)
        result["groups"] = ActiveModel::ArraySerializer.new(@groups, each_serializer: UserGroupSerializer)

        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_dashboard_quizzes_info
        @users = User.where(:active_org => params[:id], :is_valid => true)
        @quizzes = Post.where("org_id = ? AND (post_type IN (?) OR post_type IN (?)) AND is_valid AND created_at <= ?",
              params[:id],
              PostType.reference_by_base_type("quiz"),
              PostType.reference_by_base_type("safety_quiz"),
              Time.now()
            ).order("posts.created_at desc").limit(50)
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at asc')
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')

        result = {}
        result["users"] = ActiveModel::ArraySerializer.new(@users, each_serializer: UserManagementSerializer)
        result["quizzes"] = ActiveModel::ArraySerializer.new(@quizzes, each_serializer: AnnouncementManagementSerializer)
        result["locations"] = ActiveModel::ArraySerializer.new(@locations, each_serializer: LocationDashboardSerializer)
        result["groups"] = ActiveModel::ArraySerializer.new(@groups, each_serializer: UserGroupSerializer)

        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_dashboard_reports_info
        ##UserAnalytic.create(:action => 1,:org_id => params[:id], :user_id => cookies[:user_id], :ip_address => request.remote_ip.to_s)
        @users = User.where(:active_org => params[:id], :is_valid => true)
        @quizzes = Post.where("org_id = ? AND (post_type IN (?) OR post_type IN (?)) AND is_valid AND created_at <= ?",
              params[:id],
              PostType.reference_by_base_type("quiz"),
              PostType.reference_by_base_type("safety_quiz"),
              Time.now()
            ).order("posts.created_at desc").limit(50)
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at asc')
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        @attempts = PollResult.where(:org_id => params[:id], :is_valid => true).order('created_at desc')

        result = {}
        result["users"] = ActiveModel::ArraySerializer.new(@users, each_serializer: UserManagementSerializer)
        result["quizzes"] = ActiveModel::ArraySerializer.new(@quizzes, each_serializer: ReportPageQuizzesSerializer)
        result["locations"] = ActiveModel::ArraySerializer.new(@locations, each_serializer: LocationDashboardSerializer)
        result["groups"] = ActiveModel::ArraySerializer.new(@groups, each_serializer: UserGroupSerializer)
        result["attempts"] = ActiveModel::ArraySerializer.new(@attempts, each_serializer: PollResultSerializer)

        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_dashboard_settings_info
        @users = User.where(:active_org => params[:id], :validated => true, :is_valid => true)
        @invitees = Invitation.where(:org_id => params[:id], :is_invited => true, :is_valid => true)
        @ids = UserPrivilege.where(:org_id => params[:id], :is_valid => false).pluck(:owner_id)
        @ids2 = UserPrivilege.where(:org_id => params[:id], :is_valid => true, :is_approved => false).pluck(:owner_id)
        @deactivated = User.where(:id => @ids)
        @applications = User.where(:id => @ids2)
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at asc')
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        # DAVID ADDED
        # NOTE: The id is not a good attribute to query... it will only work in this case
        @organizations = Organization.where(:id => params[:id])
        # END DAVID ADDED

        result = {}
        result["users"] = ActiveModel::ArraySerializer.new(@users, each_serializer: UserManagementSerializer)
        result["invitees"] = ActiveModel::ArraySerializer.new(@invitees, each_serializer: InviteeManagementSerializer)
        result["applications"] = ActiveModel::ArraySerializer.new(@applications, each_serializer: UserManagementSerializer)
        result["deactivated"] = ActiveModel::ArraySerializer.new(@deactivated, each_serializer: UserManagementSerializer)
        result["locations"] = ActiveModel::ArraySerializer.new(@locations, each_serializer: LocationDashboardSerializer)
        result["groups"] = ActiveModel::ArraySerializer.new(@groups, each_serializer: UserGroupSerializer)
        # DAVID ADDED
        result["organizations"] = ActiveModel::ArraySerializer.new(@organizations, each_serializer: OrganizationSerializer)
        # END DAVID ADDED

        render json: { "eXpresso" => { "code" => 1, "message" => "Data fetched successfully.", "payload" => result } }
      end

      def get_user_management_info
        #@organization = Organization.find(params[:id])
        @users = User.where(:active_org => params[:id], :is_valid => true)
        #@users =  User.where(:active_org => params[:id], :is_valid => true) | Invitation.where(:org_id => params[:id], :is_valid => true)
        render json: @users, each_serializer: UserManagementSerializer
      end

      def get_invitee_management_info
        @invitees = Invitation.where(:org_id => params[:id], :is_valid => true)
        #@organization = Organization.find(params[:id])
        #@users = User.where(:active_org => params[:id], :is_valid => true)
        #@users =  User.where(:active_org => params[:id], :is_valid => true) | Invitation.where(:org_id => params[:id], :is_valid => true)
        render json: @invitees, each_serializer: UserManagementSerializer
      end

      def get_deactivated_management_info
        @ids = UserPrivilege.where(:org_id => params[:id], :is_valid => false).pluck(:owner_id)
        @deactivated = User.where(:id => @ids)
        render json: @deactivated, each_serializer: UserManagementSerializer
      end

      def get_location_management_info
        @locations =  Location.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        render json: @locations, each_serializer: LocationDashboardSerializer
      end

      def get_group_management_info
        @groups =  UserGroup.where(:org_id => params[:id], :is_valid => true).order('created_at desc')
        render json: @groups, each_serializer: UserGroupSerializer
      end

      def get_user_quiz_report
        @reports = PollResult.where(:org_id => params[:id]).order("user_id ASC")
        render json: @reports, each_serializer: QuizReportSerializer
      end

      def bulk_invitee_delete
        if Invitation.delete_all(:id => params[:ids], :org_id => params[:id])
          render json: { "eXpresso" => { "code" => 1, "message" => "Invitation bulk delete success." } }
        else
          render json: { "eXpresso" => { "code" => -129, "message" => "Invitation bulk delete failed." } }
        end
      end

      # DAVID ADDED
      def set_secure_network
        # fetch_org makes @organization accessible
        #@organization[:secure_network] = params[:secure_network] if params[:secure_network].present?

        #if @organization.save!
        if @organization.update_attribute(:secure_network, params[:secure_network])
          render json: { "eXpresso" => { "code" => 1, "message" => "Organization secure network update success." } }
        else
          render json: { "eXpresso" => { "code" => -129, "message" => "Organization secure network update failed." } }
        end
      end

      def set_profanity_filter
        if @organization.update_attribute(:profanity_filter, params[:profanity_filter])
          render json: { "eXpresso" => { "code" => 1, "message" => "Organization profanity filter update success." } }
        else
          render json: { "eXpresso" => { "code" => -130, "message" => "Organization profanity filter update failed." } }
        end
      end

      # END DAVID ADDED

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
