class Channel < ActiveRecord::Base
  belongs_to :profile_image, :class_name => "Image", :foreign_key => "channel_profile_id"

  attr_accessible	:channel_type,
  :channel_frequency,
  :channel_name,
  :channel_profile_id,
  :channel_latest_content,
  :channel_content_count,
  :owner_id,
  :member_count,
  :is_active,
  :become_active_when,
  :allow_view,
  :allow_post,
  :allow_shift_trade,
  :allow_schedule,
  :allow_announcement,
  :allow_comment,
  :allow_like,
  :allow_view_profile,
  :allow_view_covered_shifts,
  :shift_trade_require_approval,
  :is_public,
  :is_valid

  validates_uniqueness_of :channel_type, :scope => [:channel_frequency]

  def add_subscribers(list)
    list.split.each do |p|
      if Subscription.exists?(:user_id => p,:channel_id => self[:id])
        subscription = Subscription.where(:user_id => p,:channel_id => self[:id]).first
        subscription.update_attributes(:is_valid => true, :is_active => true)
      else
        subscription = Subscription.create(
          :user_id => p,
          :channel_id => self[:id],
          :is_active => true
        )
      end
    end
  end

  def subscribers_notify(message, self_id)
    subscriber_ids = Subscription.where("channel_id = #{self[:id]} AND user_id != #{self_id} AND is_valid AND is_active AND subscription_mute_notifications = 'f'").pluck('DISTINCT user_id')
    #subscriber_ids = Subscription.where(:channel_id => self[:id], :is_valid => true, :subscription_mute_notifications => false).pluck('DISTINCT user_id')
    if subscriber_ids.count > 0
      @users = User.where("id IN (#{subscriber_ids.join(", ")}) AND is_valid")
      @users.each do |user|
        if Mession.exists?(:user_id => user[:id], :is_active => true, :is_valid => true)
          @mession = Mession.where(:user_id => user[:id], :is_active => true, :is_valid => true).first
          @mession.subscriber_push("open_app", message, 4, 1, true, user)
        end
      end
    end
  end

  def subscribers_push(base_type, post_object)
    subscriber_ids = Subscription.where("channel_id = #{self[:id]} AND user_id != #{post_object[:owner_id]} AND is_valid AND is_active AND subscription_mute_notifications = 'f'").pluck('DISTINCT user_id')
    post_archtype = false
    if post_object.archtype.present? && post_object.archtype == "shift_trade"
      post_archtype = true
    end
    subscriber_ids.each do |sid|
      begin
        PushNotificationWorker.perform_async(base_type, sid, post_object[:id], post_object[:content], post_object[:title], post_object[:owner_id], post_archtype)
      rescue Exception => error
        ErrorLog.create(
          :file => "channel.rb",
          :function => "subscriber_push",
          :error => "Exception: #{error}")
      ensure
      end
    end
  end

  def tracked_subscriber_push(post_object)
    post_archtype = false
    if post_object.archtype.present? && post_object.archtype == "shift_trade"
      post_archtype = true
    end

    begin
      targets = User.joins(:subscription, :mession).where("subscriptions.channel_id = #{post_object[:channel_id]} AND subscriptions.user_id != #{post_object[:owner_id]} AND subscriptions.is_valid AND subscriptions.is_active AND messions.is_active AND subscriptions.subscription_mute_notifications = 'f'")
      @cpr = ChannelPushReport.create(
        :channel_id => post_object[:channel_id],
        :target_number => targets.count,
        :attempted => 0,
        :success => 0,
        :failed_due_to_missing_id => 0,
        :failed_due_to_other => 0
      )
      targets.each do |user|
        TrackedPushNotificationWorker.perform_async(user_object,post_object,@cpr)
      end
    rescue Exception => error
      ErrorLog.create(
        :file => "channel.rb",
        :function => "tracked_subscriber_push",
        :error => "Exception: #{error}")
    end
  end

  def subscribers_push_old(base_type, post_object)
    subscriber_ids = Subscription.where("channel_id = #{self[:id]} AND user_id != #{post_object[:owner_id]} AND is_valid AND is_active AND subscription_mute_notifications = 'f'").pluck('DISTINCT user_id')
    #subscriber_ids = Subscription.where(:channel_id => self[:id], :is_valid => true, :subscription_mute_notifications => false).pluck('DISTINCT user_id')

    if subscriber_ids.count > 0
      @users = User.where("id IN (#{subscriber_ids.join(", ")}) AND is_valid")
      @users.each do |user|
      	if Mession.exists?(:user_id => user[:id], :is_active => true, :is_valid => true)
      		@mession = Mession.where(:user_id => user[:id], :is_active => true, :is_valid => true).first
          #action, message, source=nil, source_id=nil, sound=nil, badge=nil
          @user = User.find(post_object[:owner_id])
          if post_object.archtype.present? && post_object.archtype == "shift_trade"
            message = "#{@user[:first_name]} #{@user[:last_name]} posted a shift trade request. Interested in helping out?"
            @mession.subscriber_push("open_app", message, 4, post_object[:id], nil, user)
          elsif base_type == "announcement"
            message = @user[:first_name] + " " + @user[:last_name] + " announced: " + post_object[:content]
            @mession.subscriber_push("open_detail", message, 4, post_object[:id], nil, user)
          elsif base_type == "post"
            message = @user[:first_name] + " " + @user[:last_name] + " posted: " + post_object[:content]
            @mession.subscriber_push("open_detail", message, 4, post_object[:id], nil, user)
          elsif base_type == "training"
            message = @user[:first_name] + " " + @user[:last_name] + " posted a training: " + post_object[:title]
            @mession.subscriber_push("open_training", message, 4, post_object[:id], nil, user)
          elsif base_type == "schedule"
            if post_object[:content].present?
              message = post_object[:content]
            else
              message = @user[:first_name] + " " + @user[:last_name] + " posted a schedule"
            end
            @mession.subscriber_push("open_app", message, 4, post_object[:id], nil, user)
          elsif base_type == "quiz"
            message = @user[:first_name] + " " + @user[:last_name] + " posted a quiz: " + post_object[:title]
            @mession.subscriber_push("open_quiz", message, 4, post_object[:id], nil, user)
          elsif base_type == "shift"
            message = "#{@user[:first_name]} #{@user[:last_name]} posted a shift trade request. Interested in helping out?"
            @mession.subscriber_push("open_app", message, 4, post_object[:id], nil, user)
          else
            message = @user[:first_name] + " " + @user[:last_name] + " posted: " + post_object[:content]
            @mession.subscriber_push("open_app", message, 4, post_object[:id], nil, user)
          end
      	end
      end
    end
  end

  def create_welcome_message
    @owner = User.find(self[:owner_id])
    if self[:channel_type] == "custom_feed"
      @post = Post.create(
        :channel_id => self[:id],
        :org_id => 1,
        :owner_id => 134,
        :location => @owner[:location],
        :title => "#{@owner[:first_name]} #{@owner[:last_name]} created a private group.",
        :content => "Welcome to the private group \"#{self[:channel_name]}\"! You can trade shifts, share schedules or just post moments of your day here. Only members of this group will see your posts.",
        :post_type => 1
      )
    end
  end

  def setup_subscriptions_to_custom_channel(user_ids, message)
    user_ids.each do |user_id|
      @user = User.find(user_id[:id])
      user_subscription = Subscription.create(
        :user_id => user_id[:id],
        :channel_id => self.id
      )
      if user_id != self.owner_id && Mession.exists?(:user_id => @user[:id], :is_active => true, :is_valid => true)
        begin
          @mession = Mession.where(:user_id => @user[:id], :is_active => true, :is_valid => true).first
          @mession.subscriber_push("open_app", message, 4, 1, nil, @user)
        rescue
        end
      end
    end
    self.recount
  end

	def set_profile_id(id)
    self.channel_profile_id = id
  end

  def recount
    count = Subscription.where(:channel_id => self[:id], :is_valid => true, :is_invisible => false).count
    self.update_column(:allow_view_covered_shifts, true) if self[:allow_view_covered_shifts] == false
    if self[:id] == 1
      self.update_column(:member_count, count)
    else
      self.member_count = count
    end
    if self[:is_active] == false
      str_arry = self.become_active_when.split
      if str_arry[0] == "member_count"
        if count >= str_arry[2].to_i
          self.is_active = true
          self.become_active_when = nil
          self.subscribers_notify("The channel \"#{self.channel_name}\" in your area is activated! Be the first to send everyone nearby a message.", 134)
        else
          Subscription.where(:channel_id => self[:id], :is_valid => true).each do |a|
            #a.touch
            a.update_attribute(:is_active, true)
          end
        end
      end
    end

    if self[:channel_type] == "location_feed"
      begin
        if Location.exists?(:id => self[:channel_frequency].to_i)
          @location = Location.find(self[:channel_frequency].to_i)
          @location.update_attribute(:member_count, count)
        end
      rescue
      ensure
      end
    end
    self.save
  end
end
