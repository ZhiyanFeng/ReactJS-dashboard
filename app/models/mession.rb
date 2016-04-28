# == Schema Information
#
# Table name: messions
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  org_id          :integer
#  device          :string(255)      not null
#  device_id       :string(255)      not null
#  ip_address      :string(255)
#  start           :timestamp
#  start_location  :string(255)
#  finish          :timestamp
#  finish_location :string(255)
#  push_to         :string(255)      default("")
#  push_id         :string(255)
#  session_id      :string(255)
#  is_active       :boolean          default(TRUE)
#  is_valid        :boolean          default(TRUE)
#  created_at      :timestamp
#  updated_at      :timestamp
#

class Mession < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  attr_accessible :user_id, :device, :device_id, :ip_address, :start, :start_location,
  :finish, :finish_location, :push_to, :push_id, :build, :session_id, :is_active, :org_id

  before_create :prep_record
  after_create :post_signup_engagement

  validates_presence_of :user_id, :on => :create
  validates_presence_of :device, :on => :create
  validates_presence_of :device_id, :on => :create
  validates_presence_of :push_to, :on => :create

  def post_signup_engagement
    Rails.logger.debug "post_signup_engagement #{self[:user_id]}"
    if Mession.where(:user_id => self.user_id).count == 1
      #ChrisSignupWorker.perform_in(5.minutes, user[:id], self[:id])
      PostSignupWorker.perform_in(1.hours, user[:id], self[:id])
      PostSignupWorker.perform_in(1.days, user[:id], 0)
      PostSignupWorker.perform_in(3.days, user[:id], 0)
    end
  end

  def subscriber_push(action, message, source=nil, source_id=nil, sound=nil, user_object=nil)
    begin
      user_object.update_attribute(:push_count, user_object[:push_count] + 1)
      if self.push_to == "GCM"
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = self.push_id
        #n.attributes_for_device =
        channel_id = 0
        @post = Post.find(source_id)
        if @post[:channel_id].present?
          channel_id = @post[:channel_id]
        elsif @post[:location].present? && @post[:location] > 0
          channel_id = Channel.where(:channel_type => "location_feed", :channel_frequency => @post[:location].to_s)
        else
          channel_id = 0
        end

        if channel_id > 0
          n.data = {
            :action => action, # Take out in future
            :category => action, # Take out in future
            :cat => action,
            :message => message, # Take out in future
            :msg => message,
            :org_id => self.org_id, # Take out in future
            :oid => self.org_id,
            :source => source, # Take out in future
            :source_id => source_id, # Take out in future
            :sid => source_id,
            :channel_id => channel_id, # Take out in future
            :cid => channel_id
          }
          n.save!
        end
      end

      if self.push_to == "APNS"
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = self.push_id
        n.alert = message.truncate(100)
        n.badge = user_object[:push_count]
        n.data = {
          :act => action, # Take out in future
          :cat => action,
          :oid => self.org_id,
          :src => source,
          :sid => source_id
        }
        n.save!
      end
    rescue => e

    ensure
    end
  end

  def tracked_subscriber_push(action, message, source=nil, source_id=nil, user_object, channel_id, mession_object)
    #user_object.update_attribute(:push_count, user_object[:push_count] + 1)
    User.increment_counter(:push_count,user_object[:id])
    if mession_object[:push_to] == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = mession_object[:push_id]
        if channel_id > 0
          n.data = {
            :action => action, # Take out in future
            :category => action, # Take out in future
            :cat => action,
            :message => message, # Take out in future
            :msg => message,
            :org_id => 1, # Take out in future
            :oid => 1,
            :source => source, # Take out in future
            :source_id => source_id, # Take out in future
            :sid => source_id,
            :channel_id => channel_id, # Take out in future
            :cid => channel_id
          }
          n.save!
          return 1
        end
      rescue Exception => error
        ErrorLog.create(
          :file => "mession.rb",
          :function => "tracked_subscriber_push",
          :error => "Unable to push to gcm: #{error}")
        if error.to_s.include? "Device token is invalid"
          return 3
        else
          return 2
        end
      end
    end

    if mession_object[:push_to] == "APNS"
      begin
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = mession_object[:push_id]
        n.alert = message.truncate(100)
        n.badge = user_object[:push_count]
        n.data = {
          :act => action, # Take out in future
          :cat => action,
          :oid => 1,
          :src => source,
          :sid => source_id
        }
        n.save!
        return 1
      rescue Exception => error
        ErrorLog.create(
          :file => "mession.rb",
          :function => "tracked_subscriber_push",
          :error => "Unable to push to apns: #{error}")
        if error.to_s.include? "Device token is invalid"
          return 3
        else
          return 2
        end
      end
    end
  end

  def target_push(action, message, source=nil, source_id=nil, sound=nil, badge=nil)
    if self.push_to == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = self.push_id
        #n.attributes_for_device =
        channel_id = 0
        begin
          @post = Post.find(source_id)
          if @post[:channel_id].present?
            channel_id = @post[:channel_id]
          elsif @post[:location].present? && @post[:location] > 0
            channel_id = Channel.where(:channel_type => "location_feed", :channel_frequency => @post[:location].to_s)
          else
            channel_id = 0
          end
        rescue
        end
        if channel_id > 0
          n.data = {
            :action => action,
            :category => action,
            :cat => action,
            :message => message,
            :msg => message,
            :org_id => self.org_id,
            :oid => self.org_id,
            :source => source,
            :source_id => source_id,
            :sid => source_id,
            :channel_id => channel_id,
            :cid => channel_id
          }
          n.save!
        end
      rescue
      ensure
        ErrorLog.create(
          :file => "mession.rb",
          :function => "target_push",
          :error => "unable to push gcm")
      end
    end

    if self.push_to == "APNS"
      begin
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = self.push_id
        n.alert = message
        n.badge = badge
        if sound == false
          n.sound = "silent.mp3"
        end
        #n.attributes_for_device
        n.data = {
          :action => action,
          :category => action,
          :cat => action,
          :message => message,
          :msg => message,
          :org_id => self.org_id,
          :source => source,
          :source_id => source_id,
          :sid => source_id,
          :channel_id => channel_id
        }
        n.save!
      rescue Exception => error
        ErrorLog.create(
          :file => "mession.rb",
          :function => "target_push",
          :error => "Unable to push to apns: #{error}")
      ensure
      end
    end
  end

  def push(action, message, source, source_id, sound=nil, up_badge=nil)
    if self.push_to == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = self.push_id
        #n.attributes_for_device =
        channel_id = 0
        begin
          @post = Post.find(source_id)
          if @post[:channel_id].present?
            channel_id = @post[:channel_id]
          elsif @post[:location].present? && @post[:location] > 0
            channel_id = Channel.where(:channel_type => "location_feed", :channel_frequency => @post[:location].to_s)
          else
            channel_id = 0
          end
        rescue
        end
        if channel_id > 0
          n.data = {
            :action => action,
            :category => action,
            :cat => action,
            :message => message,
            :msg => message,
            :org_id => self.org_id,
            :oid => self.org_id,
            :source => source,
            :source_id => source_id,
            :sid => source_id,
            :channel_id => channel_id,
            :cid => channel_id
          }
          n.save!
        end
      rescue
      ensure
        ErrorLog.create(
          :file => "mession.rb",
          :function => "push",
          :error => "unable to push gcm")
      end
    end

    if self.push_to == "APNS"
      begin
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = self.push_id
        n.alert = message
        #n.badge = up_badge
        if sound == false
          n.sound = "silent.mp3"
        end
        #n.attributes_for_device
        n.data = {
          :cat => action,
          :oid => self.org_id,
          :src => source,
          :sid => source_id
        }
        n.save!
      rescue
      ensure
        ErrorLog.create(
          :file => "mession.rb",
          :function => "push",
          :error => "unable to push apns")
      end
    end
  end

  def push_no_content(message, action)
    if self.push_to == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = self.push_id
        n.data = {
          :category => action,
          :message => message,
          :org_id => 1,
          :source => 4,
          :source_id => 21887,
          :channel_id => 1
        }
        n.save!
      rescue Exception => error
        ErrorLog.create(
          :file => "mession.rb",
          :function => "push_no_content",
          :error => "Unable to push to gcm: #{error}")
      end
    end

    if self.push_to == "APNS"
      begin
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        n.device_token = self.push_id
        n.alert = message
        n.data = {
          :cat => action,
          :oid => 1,
          :src => 4,
          :sid => 21887
        }
        n.save!
      rescue Exception => error
        ErrorLog.create(
          :file => "mession.rb",
          :function => "push_no_content",
          :error => "Unable to push to apns: #{error}")
      end
    end
  end

  def prep_record
    self.session_id = SecureRandom.uuid
    self.start = Time.now
    #self.ip_address = request.remote_ip
    self.ip_address = "199.168.2.1"
  end

  def push_notification(action, message, source, source_id)
    if self.push_to == "GCM"
      n = Rpush::Gcm::Notification.new
      n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
      n.registration_ids = self.push_id
      #n.attributes_for_device =
      n.data = {
        :category => message,
        :message => action,
        :org_id => self.org_id,
        :source => source,
        :source_id => source_id
      }
      n.save!
    end

    if self.push_to == "APNS"
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
      n.device_token = self.push_id
      n.alert = message
      #n.attributes_for_device
      n.data = {
        :cat => action,
        :oid => self.org_id,
        :src => source,
        :sid => source_id
      }
      n.save!
    end
  end

  def last_active_mession
    if Mession.exists?(:user_id => self[:id], :is_active => true)
      @mession = Mession.last(:user_id => self[:id],:is_active => true).last
      @mession
    else
      false
    end
  end

  def self.clean_via_device(device_id)
    @messions = Mession.where("(device_id = ?) AND is_active", device_id)
    #Rails.logger.info "#{@messions.count} clean_via_device #{user_id} #{push_id} #{device_id}"

    @messions.each do |p|
      p.update_attributes(:is_active => false, :finish => Time.now)
    end
  end

	def self.clean(user_id, push_id, device_id)
	  #@messions = Mession.where("(user_id = ? OR push_id LIKE ?) AND is_active", user_id, push_id)
    @messions = Mession.where("(user_id = ? OR push_id LIKE ? OR device_id = ?) AND is_active", user_id, push_id, device_id)
    Rails.logger.info "#{@messions.count} mession_clean #{user_id} #{push_id} #{device_id}"

    @messions.each do |p|
      p.update_attributes(:is_active => false, :finish => Time.now)
    end
  end

  def self.broadcast(org_id, category, action, source, source_id, sender_id, recipient_id, message=nil, created_at=nil, location=nil, user_group=nil)
    @organization = Organization.find(org_id)

    if action == "announcement" || action == "training" || action == "quiz"
      @sender = Organization.find(sender_id)
      sender = @sender[:name]
    elsif action == "join"
      @sender = User.find(sender_id)
      sender = @sender[:first_name] + " " + @sender[:last_name]
    else
      @sender = User.find(sender_id)
      sender = @sender[:first_name] + " " + @sender[:last_name]
    end

    if action == "announcement" || action == "training" || action == "quiz"
      @recipient = Organization.find(recipient_id)
      recipient = @recipient[:name]
    elsif action == "join"
      @recipient = Organization.find(org_id)
      recipient = @recipient[:name]
    else
      @recipient = User.find(recipient_id)
      recipient = @recipient[:first_name] + " " + @recipient[:last_name]
    end

    if location > 0 && user_group > 0
      user_list = User.where(:active_org => org_id, :location => location, :user_group => user_group).pluck(:id)
      if user_list.size > 0
        @messions = Mession.where("user_id in (#{user_list.join(", ")}) AND is_active AND push_id IS NOT NULL", org_id, sender_id)
      end
    elsif location > 0 && user_group == 0
      user_list = User.where(:active_org => org_id, :location => location).pluck(:id)
      if user_list.size > 0
        @messions = Mession.where("user_id in (#{user_list.join(", ")}) AND is_active AND push_id IS NOT NULL", org_id, sender_id)
      end
    elsif user_group > 0 && location == 0
      user_list = User.where(:active_org => org_id, :user_group => user_group).pluck(:id)
      if user_list.size > 0
        @messions = Mession.where("user_id in (#{user_list.join(", ")}) AND is_active AND push_id IS NOT NULL", org_id, sender_id)
      end
    else
      @messions = Mession.where("org_id = ? AND user_id != ? AND is_active AND push_id IS NOT NULL", org_id, sender_id)
    end
    if @messions.present?
      @messions.each do |p|
        if (action == "announcement" || action == "training" || action == "quiz" || action == "safety_quiz" || action == "safety_training") && (category == "open_detail" || category == "open_app")
          @user = User.find(p[:user_id])
          @user.update_attribute(:push_count, @user.push_count + 1)
        end
        begin
          if p[:push_to] == "GCM"
            n = Rpush::Gcm::Notification.new
            n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
            n.registration_ids = p[:push_id]
            n.deliver_after = created_at if created_at != nil
            n.data = {
              :category => category,
              :action => action,
              :org_id => org_id,
              :source => source,
              :source_id => source_id,
              :sender => sender,
              :content => message,
              :recipient => recipient
            }
            n.save!
          elsif p[:push_to] == "APNS" && category != "refresh"
            content = ""
            if action == "announcement"
              content = "Announcement: " + message
            elsif action == "training"
              content = "Training: " + message
            elsif action == "quiz"
              content = "Quiz: " + message
            elsif action == "safety_quiz"
              content = "Safety Training: " + message
            elsif action == "safety_training"
              content = "Safety Quiz: " + message
            end
            n = Rpush::Apns::Notification.new
            n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
            n.device_token = p[:push_id]
            n.alert = content.truncate(45)
            n.badge = @user[:push_count]
            n.sound = "default"
            n.deliver_after = created_at if created_at != nil
            n.data = {
              :cat => category,
              :act => action,
              :oid => org_id,
              :src => source,
              :sid => source_id,
              :sdr => sender,
              :rpt => recipient
            }
            n.save!

            #n = Rpush::Apns::Notification.new
            #n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
            #n.device_token = token
            #n.alert = message.truncate(50)
            #n.badge = badge
            #n.sound = "default"
            #n.attributes_for_device
            #n.data = {
            #  :cat => "chat",
            #  :oid => sender[:active_org],
            #  :sid => session_id,
            #  :sdr => sender[:first_name] + " " + sender[:last_name],
            #  :chd => sender[:chat_handle]
            #}
            #n.save!
          end
        rescue
        ensure
        end
      end
    end
    #Rpush.push
    #Rpush.apns_feedback
    #ActiveRecord::Base.connection.close
  end

  def self.create_notification_message(action, org_name)
    message = ""
    if action == "announcement"
      message = org_name + " has posted an announcement!"
    end
    return message
  end

end
