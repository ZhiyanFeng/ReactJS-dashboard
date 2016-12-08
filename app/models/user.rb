# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)
#  number                 :string(255)
#  password_hash          :string(255)
#  password_salt          :string(255)
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  gender                 :integer          default(0)
#  position               :string(255)      default("")
#  location               :string(255)      default("")
#  status                 :text             default("What are you up to?")
#  chat_handle            :string(255)
#  profile_id             :integer
#  active_org             :integer          default(0)
#  push_count             :integer          default(0)
#  access_key_count       :integer          default(0)
#  validated              :boolean          default(FALSE)
#  validation_hash        :string(255)      not null
#  is_valid               :boolean          default(TRUE)
#  created_at             :timestamp
#  updated_at             :timestamp
#  is_visible             :boolean          default(TRUE)
#  system_user            :boolean          default(FALSE)
#  auth_token             :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :timestamp
#

class User < ActiveRecord::Base
  #has_one :profile_image, :class_name => "Image", :foreign_key => "owner_id"
  belongs_to :profile_image, :class_name => "Image", :foreign_key => "profile_id"
  belongs_to :cover_image, :class_name => "Image", :foreign_key => "cover_id"
  #has_many :gallery_image, -> { where('images.image_type IN (2,4,5) AND is_valid').order('created_at desc') }, :class_name => "Image", :foreign_key => "owner_id"
  #has_many :user_privileges, :conditions => proc {"owner_id = #{self.id} AND org_id = #{self.active_org}"}, :class_name => "UserPrivilege", :foreign_key => "owner_id"
  has_one :mession, -> { where ["messions.is_active = 't'"] }, :class_name => "Mession", :foreign_key => "user_id"
  #has_one :mession, :class_name => "Mession", :foreign_key => "user_id", -> ["messions.is_active = ?", true]
  has_many :subscription, :class_name => "Subscription", :foreign_key => "user_id"
  has_many :user_privileges, :class_name => "UserPrivilege", :foreign_key => "owner_id"
	has_many :likes
  has_many :posts, :through => :likes
	has_many :likes
  has_many :flags, :through => :flags
  has_many :posts

  attr_accessible :status, :user_group, :location, :gender, :first_name,
  :last_name, :email, :password, :chat_handle, :active_org,
  :push_count, :is_admin, :validated, :access_key_count, :cover_id,
  :profile_id, :phone_number, :is_active, :password_reset_token, :password_reset_sent_at,
  :last_seen_at, :last_engaged_at, :shift_count, :cover_count, :shyft_score

  attr_accessor :password

  before_create :prep_record, :create_chat_handle

  before_save do
    self.email = self.email.downcase
  end

  validates_presence_of :password, :on => :create
  validates_presence_of :first_name
  validates_presence_of :last_name
  #validates_presence_of :email
  #validates_uniqueness_of :email, :case_sensitive => false
  validates_uniqueness_of :phone_number, :allow_blank => true, :allow_nil => true

  def hitting_post_threshold(channel_id)
    @channel = Channel.find(channel_id)
    if @channel[:channel_type] == "organization_feed"
      if Post.exists?(["owner_id = #{self[:id]} AND channel_id = #{channel_id} AND post_type != 19 AND created_at > now() - interval '5 minutes'"])
        true
      else
        false
      end
    else
      false
    end
  end

  def self.create_new_user(params, location_id)
    if params[:Email].present?
      setup_email = params[:Email]
    else
      #setup_email = params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,'') + "@coffeemobile.com"
      setup_email = params[:PhoneNumber].gsub(/\W/,'') + "@coffeemobile.com"
    end
    @user = User.new(
      :first_name => params[:FirstName],
      :last_name => params[:LastName],
      :email => setup_email,
      :phone_number => params[:PhoneNumber],
      :active_org => 1,
      :password => params[:Password],
      :user_group => 0,
      :location => location_id,
      :validated => true
    )
    if @user.save
      if params[:ReferralCode].present?
        ReferralAccept.create(
          :acceptor_id => @user[:id],
          :acceptor_branch_id => params[:BranchUid],
          :program_code => params[:ProgramCode].present? ? params[:ProgramCode] : "DEFAULT",
          :referral_platform => params[:ReferralPlatform].present? ? params[:ProgramCode] : "DIRECT",
          :referral_code => params[:ReferralCode],
          :referral_credit_given => 0,
          :claimed => false
        )
        begin
          progress = ReferralAccept.where("claimed = 'f' AND referral_code = ? AND program_code = ?", params[:ReferralCode], params[:ProgramCode]).count
          if count > 5
            message = "You have earned 1 referral credit from #{params[:FirstName]} #{params[:LastName]}. You can now claim you reward."
          else
            refer_more = 5 - count
            message = "You have earned 1 referral credit from #{params[:FirstName]} #{params[:LastName]}. Refer #{refer_more} more to receive a reward."
          end
          @refer = User.find_by_referral_code(params[:ReferralCode])
          @mession = Mession.where(:user_id => @refer[:id], :is_active => true).first
          if @mession
            @mession.subscriber_push("open_invites", message, 4, 7367, nil, @refer)
          end
        rescue => e
          ErrorLog.create(
            :file => "user.rb",
            :function => "self.create_new_user",
            :error => "#{e}")
        ensure
        end
      end
      # Setup profile image
      if params[:profile_image].present?
        begin
          @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
          @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
        rescue
        end
      end

      # Setup cover image
      if params[:cover_image].present?
        begin
          @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
          @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
        rescue
        end
      end

      @user
    else
      false
    end
  end

  def process_tags(tags)
    t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
    t_token = '81eaed486465b41042fd32b61e5a1b14'

    @client = Twilio::REST::Client.new t_sid, t_token

    if Rails.env.production?
      @host = "http://goo.gl/isddrw"
    elsif Rails.env.staging?
      @host = "http://goo.gl/isddrw"
    elsif Rails.env.testing?
      @host = "http://goo.gl/isddrw"
    else
      @host = "http://goo.gl/isddrw"
    end

    if self[:active_org] != 1
      @organization = Organization.where(:id => self[:active_org]).first
      network_name = @organization[:name]
    else
      @location = Location.where(:id => self[:location]).first
      network_name = @location[:location_name]
    end

    if tags.present?
      tags.each do |invitee|
        if invitee[:type] == "sms"
          begin
            message = @client.account.messages.create(
              :body => "#{self.first_name} #{self.last_name} requested you to cover a shift at #{network_name} through Coffee Mobile, download it here to help out! #{@host}",
              :to => invitee[:destination],
              :from => "+16137028842"
            )
          rescue

          end
        else
        end
      end
    end
  end

  def revoke_account
    transaction do
      @key = UserPrivilege.where(:owner_id => self.id, :org_id => self.active_org).first
      if @key[:is_root]
        return false
      end
      @mession = Mession.where(:user_id => self.id, :is_active => true).last
      @organization = Organization.find(self.active_org)
      @location = Location.find(self.location)
      if @mession.present? && @location.present?
        begin
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
          n.device_token = @mession.push_id
          n.alert = "Your access to " + @location[:location_name] + " has been revolked."
          #n.attributes_for_device
          n.data = {
            :cat => "open_app",
            :oid => self.active_org
          }
          n.save!
        rescue

        ensure

        end
        @mession.update_attribute(:is_active, false)
      end
      @key.update_attributes!(:is_approved => false, :is_admin => false, :is_valid => false)
      self.update_attribute(:active_org, 0)
    end
  end

  def revolk_account
    transaction do
      @key = UserPrivilege.where(:owner_id => self.id, :org_id => self.active_org).first
      #Rails.logger.debug(@key.inspect)
      if @key[:is_root]
        return false
      end
      @mession = Mession.where(:user_id => self.id, :is_active => true).last
      @organization = Organization.find(self.active_org)
      if @mession.present? && @organization.present?
        begin
          n = Rpush::Apns::Notification.new
          n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
          n.device_token = @mession.push_id
          n.alert = "Your access to " + @organization[:name] + " has been revolked."
          #n.attributes_for_device
          n.data = {
            :cat => "open_app",
            :oid => self.active_org
          }
          n.save!
        rescue

        ensure

        end
        @mession.update_attribute(:is_active, false)
      end
      @key.update_attributes!(:is_approved => false, :is_admin => false, :is_valid => false)
      self.update_attributes!(:active_org => 0)
    end
  end

  def send_password_reset
    #generate_token(:password_reset_token)
    self.update_attributes(
      :password_reset_token => SecureRandom.urlsafe_base64,
      :password_reset_sent_at => Time.zone.now
    )
    #self.password_reset_sent_at = Time.zone.now
    NotificationsMailer.password_reset(self).deliver
  end

  def send_password_reset_via_sms
    #generate_token(:password_reset_token)
    self.update_attributes(
      :password_reset_token => SecureRandom.urlsafe_base64,
      :password_reset_sent_at => Time.zone.now
    )

    t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
    t_token = '81eaed486465b41042fd32b61e5a1b14'

    @client = Twilio::REST::Client.new t_sid, t_token

    if Rails.env.production?
      @host = "http://api.coffeemobile.com"
    elsif Rails.env.staging?
      @host = "http://staging.coffeemobile.com"
    elsif Rails.env.testing?
      @host = "http://test.coffeemobile.com"
    else
      @host = "http://localhost:3000"
    end

    message = @client.account.messages.create(
      :body => "To reset your Shyft password, click #{@host}/reset_password/#{self.password_reset_token}",
      #:to => self[:phone_number],
      :to => self[:phone_number].size > 10 ? "+"+ self[:phone_number] : self[:phone_number],
      :from => "+16137028842"
    )
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def belongs_to(org)
    return self.org_id == org
  end

  def is_valid
    return self.is_valid?
  end

  def is_admin
    return self.is_admin?
  end

  #def indicate(user_id)
  #  self.gallery_image.each do |p|
  #    p.setup
  #  end
  #end

  def leave_org
    transaction do
      if UserPrivilege.exists?(:org_id => self[:active_org], :owner_id => self[:id], :is_valid => true)
        @key = UserPrivilege.where(:org_id => self[:active_org], :owner_id => self[:id], :is_valid => true).first
        if @key.destroy
          if UserNotificationCounter.exists?(:user_id => self[:id], :org_id => self[:active_org])
            @n = UserNotificationCounter.where(:user_id => self[:id], :org_id => self[:active_org]).first
            if @n.destroy
              self.update_attribute(:active_org, 0)
              return true
            else
              return false
            end
          end
        else
          return false
        end
      end
    end
  end

  def has_liked(obj, id)
    if Like.exists?(:owner_id => self.id, :source => Source.id_from_name(obj), :source_id => id)
      return true
    else
      return false
    end
  end

  def has_flagged(obj, id)
    if Flag.exists?(:owner_id => self.id, :source => Source.id_from_name(obj), :source_id => id)
      return true
    else
      return false
    end
  end

  def create_chat_handle
    self.chat_handle = SecureRandom.hex
    #@host = "http://chat.coffeemobile.com:9090"
    #url = "#{ @host }/plugins/userService/userservice?type=add&secret=scottyvmcsexy&username=" +
    #self.chat_handle + "&password=3635durocher&name=" + self.email
    #require 'open-uri'
    #body = open(url).read

    #@output = Nokogiri::XML(body)
    ##Rails.logger.debug(@output)
    #if @output.xpath('result').text == "ok"
    #  true
    #else
    #  errors.add(:xmpp, 'Cannot create xmpp handle')
    #  false
    #end
    true
  end

  def change_password(new_password)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(new_password, self.password_salt)
    self.save
  end

  def reset_password
    self.password_salt = BCrypt::Engine.generate_salt
    temp_password = SecureRandom.base64(8)
    self.password_hash = BCrypt::Engine.hash_secret(temp_password, password_salt)
    self.save
    return temp_password
  end

  def authenticate(password)
    if self && self.password_hash != BCrypt::Engine.hash_secret(password, self.password_salt)
      # un-authorized
      #Rails.logger.debug("un-authorized")
      401
    elsif self.validated == false
      # go to require validation
      #Rails.logger.debug("go to require validation")
      209
    elsif self.active_org == 0 || self.access_key_count == 0
      # go to org application page
      #Rails.logger.debug("go to org application page")
      210
    else
      if(UserPrivilege.exists?(:org_id => self[:active_org], :owner_id => self[:id], :is_approved => true))
        #Rails.logger.debug("good to go")
        200
      else
        #Rails.logger.debug("return 211")
        211
      end
    end
  end

  def authenticate_v_two(password)
    if self && self.password_hash != BCrypt::Engine.hash_secret(password, self.password_salt)
      # un-authorized
      #Rails.logger.debug("un-authorized")
      401
    elsif self.validated == false
      # go to require validation
      #Rails.logger.debug("go to require validation")
      209
    elsif self.active_org == 0 || self.access_key_count == 0
      # go to org application page
      #Rails.logger.debug("go to org application page")
      210
    else
      if(UserPrivilege.exists?(:org_id => self[:active_org], :owner_id => self[:id], :is_approved => true))
        #Rails.logger.debug("good to go")
        200
      else
        #Rails.logger.debug("return 211")
        211
      end
    end
  end

  def authenticate_location_based(password)
    if self && self.password_hash != BCrypt::Engine.hash_secret(password, self.password_salt)
      # un-authorized
      #Rails.logger.debug("un-authorized")
      401
    elsif self.validated == false
      # go to require validation
      #Rails.logger.debug("go to require validation")
      209
    else
      200
    end
  end

  def prep_record
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
      self.validation_hash = SecureRandom.hex(24)
    end

    if first_name.present?
      #self.first_name = self.first_name.humanize
      self.first_name = self.first_name.titleize
    end

    if last_name.present?
      #self.last_name = self.last_name.humanize
      self.last_name = self.last_name.titleize
    end
  end

  def self.location_broadcast(sender_id, location, type, event, message, source, source_id, created_at = nil, user_group=nil)
    if type == "post" || type == "safety_course"
      @users = User.where("location = ? AND id != ? AND is_valid", location, sender_id)
    else
      if location > 0 && user_group > 0
        @users = User.where("location = ? AND is_valid AND user_group = ? AND id != ?", location, user_group, sender_id)
      elsif location > 0 && user_group == 0
        @users = User.where("location = ? AND id != ? AND is_valid", location, sender_id)
      elsif user_group > 0 && location == 0
        @users = User.where("location = ? AND id != ? AND is_valid AND user_group = ?", location, sender_id, user_group)
      else
        @users = User.where("location = ? AND id != ? AND is_valid", location, sender_id)
      end
    end
    @users.each do |u|
      if event == "join"
        @notification = Notification.new(
          :source => source,
          :source_id => source_id,
          :notify_id => u[:id],
          :sender_id => sender_id,
          :recipient_id => sender_id,
          :org_id => 1,
#          :location => location,
          :event => event,
          :message => message
        )
        @notification.save
        if @mession = Mession.where(:user_id => u[:id], :is_active => true).first
          u.update_attribute(:push_count, u[:push_count] + 1)
          begin
            message = message
            @mession.target_push("open_detail", message, source, source_id, nil, u[:push_count])
          rescue

          end
        end
      end

      if event == "newsfeed_post"
        if @mession = Mession.where(:user_id => u[:id], :is_active => true).first
          u.update_attribute(:push_count, u[:push_count] + 1)
          begin
            @mession.target_push("open_app", message, source, source_id, nil, u[:push_count])
          rescue

          end
        end
      end

      if event == "shift_trade"
        if @mession = Mession.where(:user_id => u[:id], :is_active => true).first
          u.update_attribute(:push_count, u[:push_count] + 1)
          begin
            message = message
            @mession.target_push("open_app", message, source, source_id, nil, u[:push_count])
          rescue

          end
        end
      end

      if event == "schedule"
        if @mession = Mession.where(:user_id => u[:id], :is_active => true).first
          u.update_attribute(:push_count, u[:push_count] + 1)
          begin
            message = message
            @mession.target_push("schedule", message, source, source_id, nil, u[:push_count])
          rescue

          end
        end
      end

      if @counter = UserNotificationCounter.where(:user_id => u[:id], :location_id => location).last
        if type == "announcement" && (created_at == nil || created_at == "")
          @counter.update_attribute(:announcements, @counter[:announcements] + 1)
        elsif type == "post"
          @counter.update_attribute(:newsfeeds, @counter[:newsfeeds] + 1)
        elsif type == "training"
          @counter.update_attribute(:trainings, @counter[:trainings] + 1)
        elsif type == "quiz"
          @counter.update_attribute(:quizzes, @counter[:quizzes] + 1)
        elsif type == "safety_training"
          @counter.update_attribute(:safety_trainings, @counter[:safety_trainings] + 1)
        elsif type == "safety_quiz"
          @counter.update_attribute(:safety_quiz, @counter[:safety_quiz] + 1)
        else

        end
      end
    end
  end

  def self.notification_broadcast(sender_id, org_id, type, event, message, source, source_id, created_at = nil, location=nil, user_group=nil)
    if type == "post" || type == "safety_course"
      #if location > 0 && user_group > 0
      #  @users = User.where("active_org = ? AND is_valid AND location = ? AND user_group = ?", org_id, location, user_group)
      #elsif location > 0 && user_group == 0
      #  @users = User.where("active_org = ? AND is_valid AND location = ?", org_id, location)
      #elsif user_group > 0 && location == 0
      #  @users = User.where("active_org = ? AND is_valid AND user_group = ?", org_id, user_group)
      #else
      #  @users = User.where("active_org = ? AND is_valid", org_id)
      #end
      if org_id == 1
        @users = User.where("active_org = 1 AND location = ? AND id != ? AND is_valid", location, sender_id)
      else
        @users = User.where("active_org = ? AND id != ? AND is_valid", org_id, sender_id)
      end
    else
      if location > 0 && user_group > 0
        @users = User.where("active_org = ? AND is_valid AND location = ? AND user_group = ?", org_id, location, user_group)
      elsif location > 0 && user_group == 0
        @users = User.where("active_org = ? AND is_valid AND location = ?", org_id, location)
      elsif user_group > 0 && location == 0
        @users = User.where("active_org = ? AND is_valid AND user_group = ?", org_id, user_group)
      else
        @users = User.where("active_org = ? AND is_valid", org_id)
      end
      #@users = User.where("active_org = ? AND is_valid AND location = ? AND user_group = ?", org_id, location, user_group)
      #@users = User.where("active_org = ? AND id != ? AND is_valid", org_id, sender_id)
    end
    @users.each do |u|
      if @counter = UserNotificationCounter.where(:user_id => u[:id], :org_id => org_id).last
        if event == "join"
          @notification = Notification.new(
            :source => source,
            :source_id => source_id,
            :notify_id => u[:id],
            :sender_id => sender_id,
            :recipient_id => sender_id,
            :org_id => org_id,
            :event => event,
            :message => message
          )
          @notification.save
        end
        if type == "announcement" && (created_at == nil || created_at == "")
          @counter.update_attribute(:announcements, @counter[:announcements] + 1)
        elsif type == "post"
          @counter.update_attribute(:newsfeeds, @counter[:newsfeeds] + 1)
        elsif type == "training"
          @counter.update_attribute(:trainings, @counter[:trainings] + 1)
        elsif type == "quiz"
          @counter.update_attribute(:quizzes, @counter[:quizzes] + 1)
        elsif type == "safety_training"
          @counter.update_attribute(:safety_trainings, @counter[:safety_trainings] + 1)
        elsif type == "safety_quiz"
          @counter.update_attribute(:safety_quiz, @counter[:safety_quiz] + 1)
        else

        end
      end
    end
  end

  def authenticate(password)
    if self && self.password_hash != BCrypt::Engine.hash_secret(password, self.password_salt)
      # un-authorized
      #Rails.logger.debug("un-authorized")
      401
    elsif self.validated == false
      # go to require validation
      #Rails.logger.debug("go to require validation")
      209
    elsif self.active_org == 0 || self.access_key_count == 0
      # go to org application page
      #Rails.logger.debug("go to org application page")
      210
    else
      if(UserPrivilege.exists?(:org_id => self[:active_org], :owner_id => self[:id], :is_approved => true))
        #Rails.logger.debug("good to go")
        200
      else
        #Rails.logger.debug("return 211")
        211
      end
    end
  end

  def self.setup_new_org(params)
    transaction do
      if @user = User.create!(params[:user])

      else
        return -1
      end
      if @organization = Organization.new(params[:organization])

      else
        return -2
      end
      if @key = @organization.complete_web_setup(@user[:id])
        @post = Post.new(
          :org_id => @organization[:id],
          :owner_id => @user[:id],
          :title => "Welcome to " + @organization[:name],
          :content => "You have successfully created the network. Please contact hello@myshyft.com for questions or assistance.",
          :post_type => 1
        )
        @post.basic_hello
        @location = Location.new(
          :org_id => @organization[:id],
          :owner_id => @user[:id],
          :lat => params[:lat],
          :lng => params[:lng],
          :street_number => params[:organization][:street_number],
          :address => params[:organization][:address],
          :city => params[:organization][:city],
          :province => params[:organization][:province],
          :postal => params[:organization][:postal],
          :country => params[:organization][:country]
        )
        if @location.save!

        else
          return -4
        end
        NotificationsMailer.organization_validation(@user, @organization).deliver
        return 1
      else
        return -3
      end
    end
  end

  def get_referral_code
    if self[:referral_code].present?
      self[:referral_code]
    else
      code = compile_referral_code
      self.update_attribute(:referral_code, code)
      code
    end
  end

  def get_referral_count(program)
    count = ReferralAccept.where(:claimed => false, :referral_code => self[:referral_code], :referral_credit_given => 0, :program_code => program).count
    #count = ReferralAccept.where(:referral_code => self[:referral_code], :referral_credit_given => 1, :program_code => program).count
    count
  end

  def get_current_claim
    claim = Claim.where(:user_id => self[:id], :status => "PROCESSING").count
    claim
  end

  def process_verified_claim(program, number_of_referrals)
    @process_these = ReferralAccept.where(:claimed => false, :referral_code => self[:referral_code], :referral_credit_given => 0, :program_code => program).limit(number_of_referrals)
    if @process_these.update_attribute(:claimed => true)
      true
    else
      false
    end
  end

  def recalculate_scores
    #if !self[:last_recount].present?
      count_posts = Post.where("owner_id = #{self[:id]} AND is_valid = 't'").count
      count_schedules = Post.where("owner_id = #{self[:id]} AND post_type = 19 AND is_valid = 't'").count
      count_shifts = ScheduleElement.where("owner_id = #{self[:id]} AND name = 'shift' AND is_valid = 't'").count
      count_covers = ScheduleElement.where("coverer_id = #{self[:id]} AND name = 'shift' AND is_valid = 't'").count
      count_likes = Like.where("owner_id = #{self[:id]} AND is_valid = 't'").count
      count_comments = Comment.where("owner_id = #{self[:id]} AND is_valid = 't'").count
      count_groups = Channel.where("owner_id = #{self[:id]} AND channel_type = 'custom_feed' AND is_valid = 't'").count
      count_locations = UserPrivilege.where("owner_id = #{self[:id]} AND is_valid = 't'").count
      count_PM = ChatParticipant.where("user_id = #{self[:id]} AND is_valid = 't'").count
      have_profile = self[:profile_id].present? ? 10 : 0

      self[:shift_count] = count_shifts
      self[:cover_count] = count_covers
      self[:last_recount] = Time.now
      self[:shyft_score] = 0 + (count_posts * 2) + (count_schedules * 3) + (count_covers * 5) + count_likes + count_comments + (count_groups * 5) + (count_locations * 3) + (count_PM * 2) + have_profile
      self.save
      puts self[:shyft_score]
    #end
  end

  private

  def compile_referral_code
    s = SecureRandom.urlsafe_base64(4)
    if User.exists?(:referral_code => s)
      compile_referral_code
    else
      s
    end
  end

  def recalculate_shift_count
    count = 0
    #@posts = Post.where("title = 'Shift Trade' AND owner_id = #{self[:id]} AND post_type = 5 AND attachment_id IS NOT NULL")
    #@posts.each do |post|
    #  if Attachment.exists?("id = #{post[:attachment_id]} AND json like '%\"source\":11%'")
    #    count = count + 1
    #  end
    #end
    count = ScheduleElement.where("owner_id = #{self[:id]} AND name = 'shift' AND is_valid = 't'").count
    self.shift_count = count * 2
  end

  def recalculate_cover_count
    count = 0
    count = ScheduleElement.where("coverer_id = #{self[:id]} AND name = 'shift' AND is_valid = 't'").count
    self.shift_count = count
    self.shyft_score = self.shyft_score
  end
end
