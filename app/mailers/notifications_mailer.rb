class NotificationsMailer < ActionMailer::Base
	default from: "hello@myshyft.com"
	default to: "admin@myshyft.com"

  def support_admin_claim_email(email,uid,claim_id)
    @user = User.find(uid)
    @email = email
    @claim_id = claim_id
    #mail(:to => email, :subject => "New Admin Application")
    mail(:to => "support@myshyft.com", :subject => "New Admin Application #{claim_id}")
  end

  def admin_claim_confirmation_email(email,name,activation_code)
    if Rails.env.production?
      @host = "http://api.coffeemobile.com/"
    elsif Rails.env.staging?
      @host = "http://staging.coffeemobile.com/"
    elsif Rails.env.test?
      @host = "http://test.coffeemobile.com/"
    else
      @host = "http://localhost:3000/"
    end

    @user_first_name = name
    @activation_url = "#{@host}admin_activation/#{activation_code}"

    mail(:to => email, :subject => "Your application to become a Shyft Admin.")
  end

  def admin_claim_success_email(name,email)
    if Rails.env.production?
      @host = "http://api.coffeemobile.com/"
    elsif Rails.env.staging?
      @host = "http://staging.coffeemobile.com/"
    elsif Rails.env.test?
      @host = "http://test.coffeemobile.com/"
    else
      @host = "http://localhost:3000/"
    end

    @user_first_name = name

    mail(:to => email, :subject => "Your admin privileges are activated!")
  end

	def weekly_statistics(email, location_id)
    begin
  		@user = User.find_by_email(email)

      if UserPrivilege.exists?(:owner_id => @user[:id], :location_id => location_id, :is_admin => true, :is_valid => true)
        year = Time.now.year

        week_num = Time.now.strftime("%U").to_i
        week_start = Date.commercial( year, week_num, 1 )
        week_end = Date.commercial( year, week_num, 7 )

        #week_num_minus = Time.now.strftime("%U").to_i-1
        #week_minus_start = Date.commercial( year, week_num_minus, 1 )
        #week_minus_end = Date.commercial( year, week_num_minus, 7 )
        if week_num == 1
          week_num_minus = 53
          week_minus_start = Date.commercial( year-1, week_num_minus, 1 )
          week_minus_end = Date.commercial( year-1, week_num_minus, 7 )
        else
          week_num_minus = Time.now.strftime("%U").to_i-1
          week_minus_start = Date.commercial( year, week_num_minus, 1 )
          week_minus_end = Date.commercial( year, week_num_minus, 7 )
        end

        @week_dates = week_start.strftime( "%A, %B %e" ) + ' - ' + week_end.strftime("%A, %B %e" )

        @key = UserPrivilege.where(:owner_id => @user[:id], :location_id => location_id, :is_admin => true, :is_valid => true).first

        @location = Location.find(location_id)

        @user_list = UserPrivilege.where(:location_id => location_id, :is_coffee => false, :is_invisible => false, :is_valid => true)
        @removed_user_list = UserPrivilege.where(:location_id => location_id, :is_coffee => false, :is_invisible => false, :is_valid => false)
        user_id_list = @user_list.pluck(:owner_id)

        @channels = Channel.where("owner_id in (#{user_id_list.join(", ")}) OR (channel_type = 'location_feed' AND channel_frequency = '#{@location[:id]}')")
        channel_id_list = @channels.pluck(:id)
        #@post = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND is_valid AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'")
        @post = Post.where("owner_id != 134 AND channel_id in (#{channel_id_list.join(", ")}) AND is_valid AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'")
        @post_count = @post.count
        last_week_post_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND is_valid AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

        @schedule_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND post_type = 19 AND is_valid AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'").count
        last_week_schedule_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND post_type = 19 AND is_valid AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

        @user_count = ChatParticipant.where("user_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active").count
        @msg = ChatMessage.where("sender_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'")
        @msg_count = @msg.count
        last_week_msg_count = ChatMessage.where("sender_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

        message_users_list = @msg.pluck(:sender_id)
        post_user_list = @post.pluck(:owner_id)

        user_appearance = message_users_list + post_user_list
        freq = user_appearance.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
        @active_user = User.find(user_appearance.max_by { |v| freq[v] })

        @active_msg = @msg.where(:sender_id => @active_user[:id]).count
        @active_post = @post.where(:owner_id => @active_user[:id]).count

        @admins = User.where("id in (#{@user_list.where(:is_admin => true).pluck(:owner_id).join(", ")})")

        if (@msg_count + @post_count) > (last_week_msg_count + last_week_post_count)
          diff = (@msg_count + @post_count) - (last_week_msg_count + last_week_post_count)
          @compare_msg = "that's #{diff} more than the week before"
        elsif (@msg_count + @post_count) == (last_week_msg_count + last_week_post_count)
        	@schedule_message = "that's exactly the same as the week before"
        else
          diff = (last_week_msg_count + last_week_post_count) - (@msg_count + @post_count)
          @compare_msg = "that's #{diff} fewer than the week before"
        end

        if @schedule_count > last_week_schedule_count
          diff = @schedule_count - last_week_schedule_count
          @schedule_message = "that's #{diff} more than the week before"
        elsif @schedule_count == last_week_schedule_count
        	@schedule_message = "that's exactly the same as the week before"
        else
          diff = last_week_schedule_count - @schedule_count
          @schedule_message = "that's #{diff} fewer than the week before"
        end

        #Week dates in format Monday, September 1st
        #@week_dates = week_dates(week_num)

      	mail(:to => email, :subject => "[Shyft] Team update for the week of #{week_start.strftime( "%A, %B %e" )}")
      	true
      else
        false
      end
    rescue => ex
      logger.error ex.message
    end
	end

	def new_message(message)
		@message = message
		mail(:subject => "{message.first_name} sent a message through #{message.subject}")
	end

	def invitation(invitation)
		@invitation = invitation
		mail(:to => @invitation[:email], :subject => "Welcome to Coffee Enterprise.")
	end

	def send_invitation_code(invitation)
		@code = invitation[:invite_code]
		mail(:to => invitation[:email], :subject => "Verification Code: #{@code}.")
	end

	def invitation_email(email, network, invitation)
		@organization = network
		@invitation = invitation
		if @invitation[:first_name]
			@name = @invitation[:first_name]
		else
			@name = nil
		end
		mail(:to => email, :subject => "You have been invited to #{network}'s private network.")
	end

	def user_validation(user)
		@user = user
		mail(:to => "#{user.first_name} <#{user.email}>", :subject => "Welcome to Coffee Enterprise!")
	end

	def user_validation_with_invitation(user)
		@user = user
		mail(:to => "#{user.first_name} <#{user.email}>", :subject => "Welcome to Coffee Enterprise!")
	end

	def organization_validation(user, organization)
		@user = user
		@organization = organization
		mail(:to => "#{user.first_name} <#{user.email}>", :subject => "Welcome to Coffee Enterprise!")
	end

	def user_reset_password(user, password)
		@user = user
		@password = password
		mail(:to => "#{user.first_name} <#{user.email}>", :subject => "Your password has been reset.")
	end

	def password_reset(user)
		@user = user
		mail(:to => "#{user.first_name} <#{user.email}>", :subject => "Coffeemobile password reset.")
	end
end
