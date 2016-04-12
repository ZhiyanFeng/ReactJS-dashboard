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
  after_create :search_region_feed, :search_category_feed

  def search_category_feed
    @location = Location.find(location_id)
    if @location[:category] == "Cocktail Bar" || @location[:category] == "Restaurant" ||
      @location[:category] == "Irish Pub" || @location[:category] == "American Restaurant" ||
      @location[:category] == "Wings Joint" || @location[:category] == "Pizza Place" ||
      @location[:category] == "BBQ Joint" || @location[:category] == "Fast Food Restaurant"
      channel = Channel.find(5866)
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
    elsif @location[:category] == "Medical Center" || @location[:category] == "Acupuncturist" ||
      @location[:category] == "Alternative Healer" || @location[:category] == "Chiropractor" ||
      @location[:category] == "Dentist's Office" || @location[:category] == "Doctor's Office" ||
      @location[:category] == "Emergency Room" || @location[:category] == "Eye Doctor" ||
      @location[:category] == "Hospital" || @location[:category] == "Laboratory" ||
      @location[:category] == "Maternity Clinic" || @location[:category] == "Mental Health Office" ||
      @location[:category] == "Rehab Center" || @location[:category] == "Urgent Care Center" ||
      @location[:category] == "Veterinarian" || @location[:category] == "College Lab" ||
      @location[:category] == "Animal Shelter" || @location[:category] == "Funeral Home" ||
      @location[:category] == "Assisted Living"
      channel = Channel.find(6841)
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
      if location_starting_member_count = 0 && location_channel.member_count == 1
        Post.where(:channel_id => location_channel[:id]).update_all(:is_valid => false)
        @post = Post.new(
          :org_id => 1,
          :location => self[:location_id],
          :owner_id => 134,
          :channel_id => location_channel[:id],
          #:title => "Welcome to Shyft",
          #:content => "Begin trading shifts and messaging coworkers today! You now have an exclusive private network for your work location. Click on the 'Contacts' tab, then the '+' button to invite 10 staff members. Have fun!. \nPlease contact hello@myshyft.com for assistance.",
          :title => "Welcome to your Shyft Channel - Earn 25$!",
          :content => "This is the main feed for your work location to swap shifts. Use the + button to post a shift, or make a post. You can set up private groups, post schedules, chat, have fun and communicate with your team! Your channel settings are in the top right corner (gear button). Earn 25$ - We want to send your location a gift! Grow this location to 10 team members and Shyft will send a $25 gift card of your choice (Starbucks, Best Buy, Etc.) to your store. All you have to do is invite your team, and submit your store name and address to hello@myshyft.com for our review! *New employee signups only - Ends April 16th at 12:00PM EST* #ShyftLife",
          :post_type => 1
        )
        @post.save
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
