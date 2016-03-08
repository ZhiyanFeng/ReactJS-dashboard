class CpanelController < ApplicationController
  include ApplicationHelper
  before_filter :set_basics, :except => [:select, :cookies_expires]

  def set_basics
    @organization = Organization.find(cookies[:org_id])
    @profile_image = []
    if @organization[:profile_id]
      begin
        @profile_image = Image.find(@organization[:profile_id])
        @profile_url = @profile_image.thumb_url
      rescue
        @profile_url = "https://s3.amazonaws.com/coffeemobileassets/profile.png"
      end
    end
  end
  
  def select
    @keychain = UserPrivilege.where(:owner_id => current_user[:id], :is_approved => true, :is_admin => true, :is_valid => true).load
	  if @keychain.count > 1
	    @options = []
	    count = 0
	    @keychain.each do |k|
	      name = Organization.find(k[:org_id])
	      @options.insert(count, name[:name])
	      count = count + 1
      end
	    #current_user = @user
	    #@keychain = "hello"
			#cookie[:user_id] = organization.id
			#cookie[:org_id] = organization.id
			#cookies[:logged_in] = true
			#cookies[:last_seen] = Time.now
			#cookies[:expires_at] = Time.now + 60.minute
			#cookies[:organization] = Time.now
			#flash[:notice] = "Welcome back " + params[:login] + "!"
			#flash[:notice] = "Welcome back!"
			#redirect_to dashboard_url
		elsif @keychain.count == 1
		  @apikey = ApiKey.new(:app_platform => "Dashboard", :app_version => "1.0.0")
		  @apikey.save
			  cookies[:org_id] = @keychain.first[:org_id]
  			cookies[:api_key] = @apikey[:access_token]
  		  @organization = Organization.find(cookies[:org_id])
        current_organization = @organization
  		  flash[:notice] = "Welcome back!"
  			redirect_to dashboard_url
  		
		else
	    redirect_to login_url
		  flash[:notice] = "You do not have administration privileges on this account."
		end
  end
  
  def home
    @data ||= Array.new
    @post_count = Post.where(:org_id => @organization[:id]).count
    @user_count = User.where(:active_org => @organization[:id]).count
    
    query = 'SELECT "like".* FROM "likes" AS "like" FULL JOIN "users" 
    AS "user" ON "like"."owner_id"="user"."id" WHERE "user"."active_org"='+cookies[:org_id].to_s+' 
    AND "user"."is_valid" AND "like"."is_valid"'
    #Rails.logger.debug(query)
    connection = ActiveRecord::Base.connection()
    @like_count = connection.execute(query).count

    query = 'SELECT "message".* FROM "chat_messages" AS "message" FULL JOIN "chat_sessions" 
    AS "cookies" ON "message"."session_id"="cookies"."id" WHERE "cookies"."org_id"='+cookies[:org_id].to_s+' 
    AND "cookies"."is_valid" AND "message"."is_valid"'
    connection = ActiveRecord::Base.connection()
    @message_count = connection.execute(query).count
  end
  
  def announcements
    @admin = User.find(cookies[:user_id])

    @groups ||= Array.new
    group = {
      :id => 0, 
      :member_count => 0,
      :group_name => "All",
      :group_description => "",
      :group_avatar_id => nil
    }
    @groups.push(group)
    
    if @admin[:user_group].to_i != 0
      admin_group = UserGroup.find(@admin[:user_group])
      @groups.push(admin_group)
    end

    @locations ||= Array.new
    location = {
      :id => 0, 
      :member_count => 0,
      :location_address => "",
      :location_city => "",
      :location_name => "All"
    }
    @locations.push(location)

    if @admin[:location].to_i != 0
      admin_location = Location.find(@admin[:location])
      @locations.push(admin_location)
    end

    #@default_location = Location.new()
    #@locations = Location.where(:id => @admin[:location]) if @admin[:location] == 0 || @admin[:locations].!present? 
    #@groups = Location.where(:id => @admin[:user_group]) if @admin[:user_group] == 0 || @admin[:user_group].!present? 

    @announcements ||= Array.new
    @list = Post.where("org_id = ? AND post_type IN (?) AND is_valid", 
      cookies[:org_id], 
      PostType.reference_by_base_type("announcement")
    ).order("posts.created_at desc").limit(35)
    
    
    @list.each do |p|
      image_url = "https://s3.amazonaws.com/coffeemobile/placeholder-announcements.png"
      if p[:attachment_id]
        begin
          @attachment = Attachment.find(p[:attachment_id])
          image_url = @attachment.to_objs.first.full_url
          image_file_name = @attachment.to_objs.first.avatar_file_name
          image_file_size = @attachment.to_objs.first.avatar_file_size
        rescue
          image_url = "https://s3.amazonaws.com/coffeemobile/placeholder-announcements.png"
        end
      end
      @announcements.push(JSON::parse(p.to_json).merge(
          "image_url" => image_url,
          "image_file_name" => image_file_name,
          "image_file_size" => image_file_size))
    end
  end
  
  def settings
    @applicants = UserPrivilege.where(:org_id => cookies[:org_id], :is_approved => false)

    #@application.count
    #@applications.each do |a|
    #   a.user.first_name
    #

    @organization = Organization.find(cookies[:org_id])
    @user_groups = UserGroup.where(:org_id => cookies[:org_id])
    @locations = Location.where(:org_id => cookies[:org_id])
    #list = UserPrivilege.where(:org_id => cookies[:org_id], :is_approved => true, :is_valid => true, :is_admin => false).where('user_privileges.owner_id <> ?', cookies[:user_id].to_i).pluck(:owner_id)
    #@users = User.where(:id => list).load

    #list = UserPrivilege.where(:org_id => cookies[:org_id], :is_approved => true, :is_valid => true, :is_admin => true).where('user_privileges.owner_id <> ?', cookies[:user_id].to_i).pluck(:owner_id)
    #@admins = User.where(:id => list).load

    @users = User.where(:active_org => cookies[:org_id], :is_valid => true)
    #@formatted_users = ActiveModel::ArraySerializer.new(@users, each_serializer: UserProfileSerializer)
  end
  
  def trainings
    @admin = User.find(cookies[:user_id])

    @groups ||= Array.new
    group = {
      :id => 0, 
      :member_count => 0,
      :group_name => "All",
      :group_description => "",
      :group_avatar_id => nil
    }
    @groups.push(group)
    
    if @admin[:user_group].to_i != 0
      admin_group = UserGroup.find(@admin[:user_group])
      @groups.push(admin_group)
    end

    @locations ||= Array.new
    location = {
      :id => 0, 
      :member_count => 0,
      :location_address => "",
      :location_city => "",
      :location_name => "All"
    }
    @locations.push(location)
    if @admin[:location].to_i != 0
      admin_location = Location.find(@admin[:location])
      @locations.push(admin_location)
    end

    @trainings ||= Array.new
    @list = Post.where("org_id = ? AND post_type IN (?) AND is_valid", 
      cookies[:org_id], 
      PostType.reference_by_base_type("training")
    ).order("posts.updated_at asc").limit(35)
    
    
    @list.each do |p|
      image_url = "../assets/placeholder-trainings.png"
      if p[:attachment_id]
        begin
          @attachment = Attachment.find(p[:attachment_id]).to_objs.first
          thumb_url = @attachment.thumb_url
          video_url = @attachment.video_url
          video_file_name = @attachment.video_file_name
          video_file_size = @attachment.video_file_size
          video_id  = @attachment.video_id 

          encoded_state = @attachment.encoded_state

          video_duration  = @attachment.video_duration
        rescue
          image_url = "../assets/placeholder-trainings.png"
        end
      end

      @trainings.push(JSON::parse(p.to_json).merge(
          "thumb_url" => thumb_url,
          "video_url" => video_url,
          "video_file_name" => video_file_name,
          "video_file_size" => video_file_size,
          "video_id" => video_id,
          "encoded_state" => encoded_state,
          "video_duration" => video_duration))
    end
  end
  
  def chats
    session_ids = ChatParticipant.where(:user_id => cookies[:user_id], :is_active => true).pluck(:session_id)
    @sessions = ChatSession.where(["id IN(?) AND is_valid AND is_active", session_ids]).order("updated_at desc").load
  end
  
  def quizzes
    @admin = User.find(cookies[:user_id])

    @groups ||= Array.new
    group = {
      :id => 0, 
      :member_count => 0,
      :group_name => "All",
      :group_description => "",
      :group_avatar_id => nil
    }
    @groups.push(group)
    
    if @admin[:user_group].to_i != 0
      admin_group = UserGroup.find(@admin[:user_group])
      @groups.push(admin_group)
    end

    @locations ||= Array.new
    location = {
      :id => 0, 
      :member_count => 0,
      :location_address => "",
      :location_city => "",
      :location_name => "All"
    }
    @locations.push(location)
    if @admin[:location].to_i != 0
      admin_location = Location.find(@admin[:location])
      @locations.push(admin_location)
    end

    @quizzes ||= Array.new
    @list = Post.where("org_id = ? AND post_type IN (?) AND is_valid", 
      cookies[:org_id], 
      PostType.reference_by_base_type("quiz")
    ).order("posts.created_at desc").limit(50)
    
    
    @list.each do |p|
      image_url = "http://coffeemobile.com/assets/placeholder.jpeg"
      if p[:attachment_id]
        begin
          @attachment = Attachment.find(p[:attachment_id])
          poll = @attachment.to_objs.first.id
          question_count = @attachment.to_objs.first.question_count
          count_down = @attachment.to_objs.first.count_down
          pass_mark = @attachment.to_objs.first.pass_mark
          start_at = @attachment.to_objs.first.start_at
          end_at = @attachment.to_objs.first.end_at
        rescue
          poll = nil
        end
      end
      #Rails.logger.debug("TEST")
      #Rails.logger.debug(poll)
      #Rails.logger.debug("TESTEND")
      @quizzes.push(JSON::parse(p.to_json).merge(
          "poll_id" => poll,
          "question_count" => question_count,
          "count_down" => count_down,
          "pass_mark" => pass_mark,
          "start_at"=>start_at,
          "end_at"=>end_at))
    end
    
    #Rails.logger.debug(@quizzes)
    
  end
  
  def reports
    @user_groups = UserGroup.where(:org_id => cookies[:org_id])
    @locations = Location.where(:org_id => cookies[:org_id])
    @users =  User.where(:active_org => cookies[:org_id])
  end
  
  def schedules
    @month = (params[:month] || Time.zone.now.month).to_i
    @year = (params[:year] || Time.zone.now.year).to_i

    @shown_month = Date.civil(@year, @month)

    @event_strips = ScheduleElement.event_strips_for_month(@shown_month)
  end
  
  def analyze
    @results = {}
    File.open('log/api.log').each do |line|
      if match = line.match(/^\[(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}.\d{3})\]\s\[(\w*)\]\s\[(\w*)\.(\w*)\]\s(.*)\s\((.*)\)/i)
        datetime, type, mod, pro, info, pid = match.captures
        key = self.round_to_15_minutes(datetime)
        if mod == "users"
          if pro == "notifications"
            if @results[key.to_s].presence
              @results[key.to_s] += 1
            else
              @results[key.to_s] = 1
            end
          end
        end
      end
    end
    render json: @results
  end
  
  def round_to_15_minutes(t)
    rounded = Time.at((t.to_time.to_i / 900.0).round * 900)
    t.is_a?(DateTime) ? rounded.to_datetime : rounded
  end
  
  def round_to_10_minutes(t)
    rounded = Time.at((t.to_time.to_i / 600.0).round * 600)
    t.is_a?(DateTime) ? rounded.to_datetime : rounded
  end
  
  def cookies_expires
    a = cookies[:expires_at]
    b = Time.now
    minutes = (a-b)/1.minute
    if b > a
      reset_cookies
      flash[:error] = 'Session Expire !'
      redirect_to login_path
    else
      cookies[:expires_at] = Time.now + 60.minute
    end
  end
  
  def coming_soon
    
  end
end
