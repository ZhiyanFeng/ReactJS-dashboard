# == Schema Information
#
# Table name: user_privileges
# Geocoder::Calculations.distance_between([43.777202,-79.345148], [43.777599,-79.345136])
#  id          :integer          not null, primary key
#  owner_id    :integer          not null
#  org_id      :integer          not null
#  is_approved :boolean          default(FALSE)
#  is_admin    :boolean          default(FALSE)
#  read_only   :boolean          default(FALSE)
#  is_valid    :boolean          default(TRUE)
#  created_at  :timestamp
#  updated_at  :timestamp
#  is_root     :boolean          default(FALSE)
#

class UserPrivilege < ActiveRecord::Base
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"
  belongs_to :user, :class_name => "User", :foreign_key => "owner_id"

  attr_accessible :owner_id,
    :org_id,
    :location_id,
    :read_only,
    :is_approved,
    :is_admin,
    :is_system,
    :is_coffee,
    :is_invisible,
    :is_valid,
    :is_root

  validates_presence_of :owner_id, :on => :create
  validates_presence_of :org_id, :on => :create
  #validates_uniqueness_of :owner_id, :scope => [:org_id]
  after_create :search_region_feed
  #after_create :search_category_feed

  def search_category_feed
    server_life_15773_cats = ["food","restaurant","meal_takeaway","bar","bakery","night_club","lodging","Cocktail Bar","Restaurant","Irish Pub","American Restaurant","Wings Joint","Pizza Place","BBQ Joint","Fast Food Restaurant"]
    nursing_life_6841_cats = ["hospital","Medical Center","Acupuncturist","Alternative Healer","Chiropractor","Dentist's Office","Doctor's Office","Emergency Room","Eye Doctor","Hospital","Laboratory","Maternity Clinic","Mental Health Office","Rehab Center","Urgent Care Center","Veterinarian","College Lab","Animal Shelter","Funeral Home","Assisted Living"]
    begin
      @location = Location.find(location_id)
      if @location[:category].present? && !(@location[:location_name].downcase.include?"mcdonald") && !(@location[:location_name].downcase.include?"starbucks")
        categories = @location[:category].split(',')
        if (server_life_15773_cats - categories).size < server_life_15773_cats.size
          if Channel.exists?(:id => 15773) #Server_Life
            channel = Channel.find(15773) #Server_Life
            if !Subscription.exists?(:user_id => self[:owner_id],:channel_id => channel[:id])
              region_subscription = Subscription.create(
                :user_id => self[:owner_id],
                :channel_id => channel[:id],
                :is_active => true
              )
            else
              region_subscription = Subscription.where(:user_id => self[:owner_id],:channel_id => channel[:id]).first
              region_subscription.update_attributes(:is_valid => true, :is_active => true)
            end
            channel.recount
          else
            t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
            t_token = '81eaed486465b41042fd32b61e5a1b14'

            @client = Twilio::REST::Client.new t_sid, t_token
            message = @client.account.messages.create(
              :body => "Just hit the money block",
              :to => "4252456668",
              :from => "+16282225569"
            )
          end
        else
          #This location does not belong to server life
        end

        if (nursing_life_6841_cats - categories).size < nursing_life_6841_cats.size
          if Channel.exists?(:id => 15773) #Server_Life
            channel = Channel.find(15773) #Server_Life
            if !Subscription.exists?(:user_id => self[:owner_id],:channel_id => channel[:id])
              region_subscription = Subscription.create(
                :user_id => self[:owner_id],
                :channel_id => channel[:id],
                :is_active => true
              )
            else
              region_subscription = Subscription.where(:user_id => self[:owner_id],:channel_id => channel[:id]).first
              region_subscription.update_attributes(:is_valid => true, :is_active => true)
            end
            channel.recount
          else
            t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
            t_token = '81eaed486465b41042fd32b61e5a1b14'

            @client = Twilio::REST::Client.new t_sid, t_token
            message = @client.account.messages.create(
              :body => "Just hit the money block 2",
              :to => "4252456668",
              :from => "+16282225569"
            )
          end
        else
          #This location does not belong to nursing life
        end
      end
    rescue => e
      ErrorLog.create(
        :file => "user_privilege.rb",
        :function => "search_category_feed",
        :error => "#{e}")
    end
  end

  def search_region_feed
    @location = Location.find(location_id)
    @channels = Channel.where("channel_frequency LIKE ? OR channel_frequency LIKE ? OR channel_frequency ~ ?", "%brand_center_at:#{@location[:location_name].downcase.gsub("'",'').split.first}:%", "%geo_center_at:%", "^location_id_in:[0-9|]*\\|#{location_id}\\|")
    @channels.each do |channel|
      type = channel[:channel_frequency].split(":")[0]
      if type == "geo_center_at"
        coordinate = channel[:channel_frequency].split(":")[1].split(",")
        distance = channel[:channel_frequency].split(":")[2]
        #if Geocoder::Calculations.distance_between(coordinate, "#{@location[:lng]},#{@location[:lat]}") < distance.to_f
        if Location.distance_between([coordinate[1].to_f,coordinate[0].to_f], [@location[:lat].to_f,@location[:lng].to_f]) < distance.to_f
          if !Subscription.exists?(:user_id => self[:owner_id],:channel_id => channel[:id])
            region_subscription = Subscription.create(
              :user_id => self[:owner_id],
              :channel_id => channel[:id],
              :is_active => true
            )
          else
            region_subscription = Subscription.where(:user_id => self[:owner_id],:channel_id => channel[:id]).first
            region_subscription.update_attribute(:is_valid, true)
          end
          channel.recount
        end
      elsif type == "brand_center_at"
        coordinate = channel[:channel_frequency].split(":")[2].split(",")
        distance = channel[:channel_frequency].split(":")[3]
        if Location.distance_between([coordinate[1].to_f,coordinate[0].to_f], [@location[:lat].to_f,@location[:lng].to_f]) < distance.to_f
          if !Subscription.exists?(:user_id => self[:owner_id],:channel_id => channel[:id])
            region_subscription = Subscription.create(
              :user_id => self[:owner_id],
              :channel_id => channel[:id],
              :is_active => true
            )
          else
            region_subscription = Subscription.where(:user_id => self[:owner_id],:channel_id => channel[:id]).first
            region_subscription.update_attribute(:is_valid, true)
          end
          channel.recount
        end
      elsif type == "location_id_in"
        if !Subscription.exists?(:user_id => self[:owner_id],:channel_id => channel[:id])
          region_subscription = Subscription.create(
            :user_id => self[:owner_id],
            :channel_id => channel[:id],
            :is_active => true
          )
        else
          region_subscription = Subscription.where(:user_id => self[:owner_id],:channel_id => channel[:id]).first
          region_subscription.update_attribute(:is_valid, true)
        end
        channel.recount
      else

      end
    end
  end

  def setup_coffee_admin_subscriptions(location)
    transaction do
      coffee_channel = Channel.where(:channel_type => "coffee_feed").first
      if !Subscription.exists?(:user_id => self[:owner_id], :channel_id => coffee_channel[:id])
        #coffee_channel = Channel.where(:channel_type => "coffee_feed").first
        coffee_subscription = Subscription.create(
          :user_id => self[:owner_id],
          :channel_id => coffee_channel[:id],
          :is_active => true,
          :is_coffee => true,
          :is_invisible => true
        )
      end

      if Channel.exists?(:channel_type => "location_feed", :channel_frequency => self[:location_id].to_s)
        location_channel = Channel.where(:channel_type => "location_feed", :channel_frequency => self[:location_id].to_s).first
      else
        location_channel = Channel.create(
          :channel_type => "location_feed",
          :channel_frequency => location[:id].to_s,
          :channel_name => location[:location_name],
          :owner_id => 134
        )
      end
      location_subscription = Subscription.create(
        :user_id => self[:owner_id],
        :channel_id => location_channel[:id],
        :is_active => true,
        :is_coffee => true,
        :is_invisible => true
      )
    end
  end

  def setup_location_subscriptions(location, is_active, user)
    make_post = false
    transaction do
      @user = User.find(self[:owner_id])
      @user.update_attribute(:access_key_count, @user[:access_key_count] + 1) if is_active
      # the official coffee feed where everyone subscribes to
      coffee_channel = Channel.where(:channel_type => "coffee_feed").first
      if !Subscription.exists?(:user_id => self[:owner_id], :channel_id => coffee_channel[:id])
        #coffee_channel = Channel.where(:channel_type => "coffee_feed").first
        coffee_subscription = Subscription.create(
          :user_id => self[:owner_id],
          :channel_id => coffee_channel[:id],
          :is_active => is_active
        )
        coffee_channel.recount
      end
      # the locational feed where everyone subscribes to
      if Channel.exists?(:channel_type => "location_feed", :channel_frequency => self[:location_id].to_s)
        location_channel = Channel.where(:channel_type => "location_feed", :channel_frequency => self[:location_id].to_s).first
      else
        location_channel = Channel.create(
          :channel_type => "location_feed",
          :channel_frequency => location[:id].to_s,
          :channel_name => location[:location_name],
          :owner_id => 134
        )
      end
      location_starting_member_count = location_channel[:member_count]
      if Subscription.exists?(:user_id => self[:owner_id], :channel_id => location_channel[:id])
        @subscription = Subscription.where(:user_id => self[:owner_id], :channel_id => location_channel[:id]).first
        @subscription.update_attributes(:is_valid => true, :is_active => true)
      else
        make_post = true
        location_subscription = Subscription.create(
          :user_id => self[:owner_id],
          :channel_id => location_channel[:id],
          :is_active => is_active
        )
      end
      location_channel.recount
      if location_starting_member_count == 0 && location_channel.member_count == 1
        Post.where(:channel_id => location_channel[:id]).update_all(:is_valid => false)

        @post = Post.new(
          :org_id => 1,
          :location => self[:location_id],
          :owner_id => 134,
          :channel_id => location_channel[:id],
          :title => "Welcome to Shyft!",
          :attachment_id => 126234,
          #:content => "This is the main feed for your work location to swap shifts. Use the + button to post a shift, or make a post. You can set up private groups, post schedules, chat, have fun and communicate with your team! Your channel settings are in the top right corner (gear button). Earn 25$ - We want to send your location a gift! Grow this location to 15 team members and Shyft will send a $25 gift card of your choice to your store. All you have to do is invite your team, and submit your store name and address to hello@myshyft.com for our review! ​*New employee signups only - Ends #{(Date.today+5.days).to_formatted_s(:long_ordinal)} at 12:00PM EST* \n\n#ShyftLife 📱🔁📆🙋",
          :content => "Welcome to Shyft! We hope we make work a little easier for you. To have a digital $20 Gift card emailed to you, simply do these two things before #{(Date.today+5.days).to_formatted_s(:long_ordinal)} 12:00PM EST* \n\n1. Get 10 coworkers to join this location.\n2. Have your leader claim admin status in your channel settings.\nThen email us your store name to hello@myshyft.com\n*Limit of one gift card per location*\nThe Shyft Team 📱📆🔄😎",
          :post_type => 2
        )
        @post.save

        #begin
        #  create_AB_test_post(location[:id],location_channel[:id])
        #rescue
        #ensure
        #end
      end

      if make_post
        type = user[:profile_id].blank? ? 5 : 6
        begin
          @post = Post.new(
            :org_id => 1,
            :location => user[:location],
            :owner_id => user[:id],
            :title => "New Member!",
            :content => "Hello, my name is " + user[:first_name] + " " + user[:last_name] + ", I am the newest member of the network.",
            :post_type => type,
            :channel_id => location_channel[:id]
          )
          @post.save
          #location_channel.subscribers_push("post", @post)
          location_channel.tracked_subscriber_push("post", @post)
        rescue

        end
      end
    end
  end

  # This is for the AB testing method
  def create_AB_test_post(location_id, channel_id)
    if location_id % 4 == 0
      @post = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "Want to get a shift covered? Tap the + Button at the bottom of this screen and select 'Shift' then try adding your details and press post! Click here for other features: http://bit.ly/LiteUserGuide",
          #image 3
          :attachment_id => 82229,
          #:attachment_id => 7507,
          :post_type => 6
        )
      @post.save
    elsif location_id % 4 == 1
      @post = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "Managers get admin features! Click the gear button in the top right hand corner of this screen and select 'I Am A Manager'. Click here for other features: http://bit.ly/LiteUserGuide",
          #image 4
          :attachment_id => 82231,
          #:attachment_id => 7508,
          :post_type => 6
        )
      @post.save
    elsif location_id % 4 == 2
      @post = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "Snap & Share your schedule! Select the schedule tab, then take a quick snap of your schedule, enter your details and post it! Click here for other features: http://bit.ly/LiteUserGuide",
          #image 6
          :attachment_id => 82233,
          #:attachment_id => 7510,
          :post_type => 6
        )
      @post.save
    elsif location_id % 4 == 3
      @post3 = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "Want to get a shift covered? Tap the + Button at the bottom of this screen and select 'Shift' then try adding your details and press post! Click here for other features: http://bit.ly/LiteUserGuide",
          #image 3
          :attachment_id => 82229,
          #:attachment_id => 7507,
          :post_type => 6
        )
      @post3.save

      @post2 = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "",
          #image 2
          :attachment_id => 82228,
          #:attachment_id => 7506,
          :post_type => 6
        )
      @post2.save

      @post1 = Post.new(
          :org_id => 1,
          :location => location_id,
          :owner_id => 134,
          :channel_id => channel_id,
          :title => "Shyft tutorial",
          :content => "",
          #image 1
          :attachment_id => 82236,
          #:attachment_id => 7505,
          :post_type => 6
        )
      @post1.save
    else
    end
  end

  def create_location_key
    if self.save
      if @user = User.find(self[:owner_id])
        counter = UserNotificationCounter.create(:user_id => @user[:id], :org_id => @user[:active_org])
        begin
          @user.update_attributes(:access_key_count => @user.access_key_count + 1, :validated => true)
          if @organization.secure_network
            self[:is_approved] = false
            self.save
          else
            self[:is_approved] = true
            self.save
          end
        rescue

        ensure

        end
      end
    end
  end

  def create_open_key
    if save
      if @organization = Organization.find(self[:org_id])
        if @user = User.find(self[:owner_id])
          counter = UserNotificationCounter.new(:user_id => @user[:id], :org_id => @user[:active_org])
          counter.save
          begin
            #@mession = Mession.where(:user_id => self[:owner_id], :is_active => true).last
            #@mession.update_attribute(:org_id, 1)
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :validated => true)
            #self.update_attribute(:is_approved, true)
            if @organization.secure_network
              self[:is_approved] = false
              self.save
            else
              self[:is_approved] = true
              self.save
            end

          rescue
            errors[:base] << "Could not update the mession"
            return false
          end
          begin
            type = @user[:profile_id].blank? ? 5 : 6
            begin
              @post = Post.new(
                :org_id => @user[:active_org],
                :location => @user[:location],
                :owner_id => @user[:id],
                :title => "New Member!",
                :content => "Hello, my name is " + @user[:first_name] + " " + @user[:last_name] + ", I am the newest member of the network.",
                :post_type => type
              )
            rescue
              errors[:base] << "Couldn't setup the post object"
              return false
            end
            if type == 6
              begin
                @post.hello_with_image(@user[:profile_id])
              rescue
                errors[:base] << "Couldn't create image post"
                return false
              end
            else
              begin
                @post.basic_hello
              rescue
                errors[:base] << "Couldn't create normal post"
                return false
              end
            end
            begin
              Follower.follow(4, @post[:id], @user[:id])
            rescue
              errors[:base] << "Couldn't setup as follower"
              return false
            end
            begin
              message = @user[:first_name] + " " + @user[:last_name] + " joined your location."
              User.location_broadcast(@user[:id], @user[:location], "post", "join", message, 4, @post[:id]) if @user[:location] != 0
            rescue
              errors[:base] << "Couldn't location broadcast"
              return false
            end
          rescue
            errors[:base] << "Could not create the post"
            return false
          end
        else
          errors[:base] << "Couldn't find User with id=" + owner_id
          return false
        end
      else
        errors[:base] << "Couldn't find the network"
        return false
      end
    else
      errors[:base] << "Couldn't save the key"
      return false
    end
  end

  def create_key_for(is_admin, is_approved=false)
    if save
      if @organization = Organization.find(self[:org_id]) && @location = Location.find(self[:location_id])
        if @user = User.find(self[:owner_id])
          counter = UserNotificationCounter.new(:user_id => @user[:id], :org_id => self[:org_id])
          counter.save
          begin
            @mession = Mession.where(:user_id => self[:owner_id], :is_active => true).last
            @mession.update_attribute(:org_id, self[:org_id])
          rescue
            #Rails.logger.debug("user_privilege.rb line 41: cannot find messions")
          end
          if @organization.secure_network
            #if the organization requires approval
            if is_admin || is_approved
              self[:is_approved] = true
            else
              self[:is_approved] = false
            end
            self[:is_admin] = true if is_admin
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id], :validated => true)
            #@user.update_attributes(:access_key_count => @user.access_key_count + 1)
          else
            self[:is_approved] = true
            self[:is_admin] = true if is_admin
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id], :validated => true)
          end
          self.save
          @user.save
          begin
            type = @user[:profile_id].blank? ? 5 : 6
            @post = Post.new(
              :org_id => self[:org_id],
              :owner_id => @user[:id],
              :title => "New Member!",
              :content => "Hello, I am the newest member of " + @location[:location_name] + ".",
              #:content => "Hello, I am the newest member of " + organization[:name] + ".",
              :post_type => type
            )
            if type == 6
              @post.hello_with_image(@user[:profile_id])
            else
              @post.basic_hello
            end
            Follower.follow(4, @post[:id], @user[:id])
            message = @user[:first_name] + " " + @user[:last_name] + " joined #{@location[:location_name]}!"
            User.notification_broadcast(@user[:id], @post[:org_id], "post", "join", message, 4, @post[:id])
            Mession.broadcast(@post[:org_id], "open_app", "join", 4, @post[:id], @user[:id], @user[:id])
          rescue
            #Rails.logger.debug("user_privilege.rb line 76: can't create post.")
          end
          return true
        else
          errors[:base] << "Couldn't find User with id=" + owner_id
          return false
        end
      else
        errors[:base] << "Couldn't find Organization with id=" + org_id
        return false
      end
    end
  end

  def create_key_for_web(is_admin)
    if save
      if @organization = Organization.find(self[:org_id])
        if @user = User.find(self[:owner_id])
          counter = UserNotificationCounter.new(:user_id => @user[:id], :org_id => self[:org_id])
          counter.save
          begin
            @mession = Mession.where(:user_id => self[:owner_id], :is_active => true).last
            @mession.update_attribute(:org_id, self[:org_id])
          rescue
            #Rails.logger.debug("user_privilege.rb line 41: cannot find messions")
          end
          if @organization.secure_network
            #if the organization requires approval
            self[:is_approved] = true
            self[:is_admin] = true if is_admin
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id])
            #@user.update_attributes(:access_key_count => @user.access_key_count + 1)
          else
            self[:is_approved] = true
            self[:is_admin] = true if is_admin
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id])
          end
          self.save
          @user.save
        else
          errors[:base] << "Couldn't find User with id=" + owner_id
          return false
        end
      else
        errors[:base] << "Couldn't find Organization with id=" + org_id
        return false
      end
    end
  end

  def grant_access
    transaction do
      if save
        if Organization.exists?(self.org_id)
          #@organization = Organization.find(self.org_id)
          @user = User.find(self.owner_id)
          #unless @organization.secure_network
            #if the organization requires approval
          self.is_approved = true
          #end
          @user.update_attribute(:access_key_count, @user.access_key_count + 1)
        else
          errors[:base] << "Couldn't find Organization with id=" + org_id
          return false
        end
      end
    end
  end

  def revoke_access
    transaction do
      self.update_attribute(:is_approved => false)
      @user = User.find(self.owner_id)
      @user.update_attribute(:access_key_count, @user.access_key_count - 1)
    end
  end

  def reject
    transaction do
      @user = User.find(self.owner_id)
      @user.update_attributes(
        :access_key_count => @user.access_key_count - 1,
        :active_org => 0
      )
      self.destroy
    end
  end

  def approve
    transaction do
      @user.update_attributes(
        :access_key_count => @user.access_key_count - 1,
        :active_org => 0
      )
      self.update_attribute(:is_approved, true)
    end
  end

  def invalidate_key
    transaction do
      self.update_attributes(:is_valid => false, :is_approved => false)
      @user = User.find(self.owner_id)
      @user.update_attribute(:access_key_count, @user.access_key_count - 1)
    end
  end
end
