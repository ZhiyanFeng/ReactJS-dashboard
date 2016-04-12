# == Schema Information
#
# Table name: organizations
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  address         :string(255)
#  city            :string(255)
#  province        :string(255)
#  country         :string(255)
#  status          :string(255)
#  description     :string(255)
#  profile_id      :integer
#  secure_network  :boolean          default(TRUE)
#  validated       :boolean          default(FALSE)
#  validation_hash :string(255)      not null
#  is_valid        :boolean          default(TRUE)
#  created_at      :timestamp
#  updated_at      :timestamp
#

class Organization < ActiveRecord::Base
  belongs_to :profile_image, :class_name => "Image", :foreign_key => "profile_id"
  belongs_to :cover_image, :class_name => "Image", :foreign_key => "cover_id"
  has_many :gallery_image, -> { where ['images.image_type IN (1,3) AND is_valid'] }, :class_name => "Image", :foreign_key => "org_id"
  has_many :locations, -> { where ['is_valid'] }, :class_name => "Location", :foreign_key => "org_id"
  has_many :user_groups, -> { where ['is_valid'] }, :class_name => "UserGroup", :foreign_key => "org_id"
  has_many :user_privileges
  has_many :users, :through => :user_privileges
  has_many :posts
  #has_many :keys, :class_name => "Access_Key", :foreign_key => "org_id"

  attr_accessible :name, :street_number, :address, :city, :province, :postal, :country, :status,
  :description, :profile_id, :validation_hash, :has_validated, :email_domain, :unit_number, :profanity_filter

  before_create :prep_record

  validates_presence_of :name, :on => :create
  #validates_presence_of :address, :on => :create
  #validates_presence_of :city, :on => :create
  #validates_presence_of :country, :on => :create

  def profile_url
    image_url = "http://66.228.58.218/assets/coffee-badge.png"
    if self.profile_id.presence
      image = Image.find(profile_id)
      image_url = image.thumb_url
    end
    return image_url
  end

  def prep_record
    self.validation_hash = SecureRandom.hex(24)
  end

#if @key = @organization.complete_setup(params[:user_id])
          # REMOVE WHEN FIXED
          #if params[:organization][:profile_id].presence
          #  @image = Image.find(params[:organization][:profile_id])
          #  @image.update_attribute(:org_id, @organization[:id])
          #end

#if @organization = Organization.find(self[:org_id])
#        if @user = User.find(self[:owner_id])
#          counter = UserNotificationCounter.new(:user_id => @user[:id], :org_id => self[:org_id])
#          counter.save
#          begin
#            @mession = Mession.where(:user_id => self[:owner_id], :is_active => true).last
#            @mession.update_attribute(:org_id, self[:org_id])
#          rescue
#            Rails.logger.debug("user_privilege.rb line 41: cannot find messions")
#          end
#          if @organization.secure_network
#            #if the organization requires approval
#            self[:is_approved] = true
#            self[:is_admin] = true if is_admin
#            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id])
#            #@user.update_attributes(:access_key_count => @user.access_key_count + 1)
#          else
#            self[:is_approved] = true
#            self[:is_admin] = true if is_admin
#            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => self[:org_id])
#          end
#          self.save
#          @user.save
#        else
#          errors[:base] << "Couldn't find User with id=" + owner_id
#          return false
#        end
#      else
#
#
#

  def self.setup_new_org(source, params)
    transaction do

      #Setup organization
      if @organization = Organization.create!(params[:organization])

      else
        return "!Organization"
      end

      #Setup user
      if source == "app"
        if @user = User.find(params[:user_id])

        else
          return "!User"
        end
      elsif source == "web"
        if @user = User.create!(params[:user])

        else
          return "!User"
        end
      else

      end

      #Setup user privilege
      if @key = UserPrivilege.create!(:org_id => @organization[:id], :owner_id => @user[:id])
        if counter = UserNotificationCounter.create!(:user_id => @user[:id], :org_id => @organization[:id])
          #Update current mobile session to reflect update in active organization
          begin
            @mession = Mession.where(:user_id => @user[:id], :is_active => true).last
            @mession.update_attribute(:org_id, @organization[:id])
          rescue
            Rails.logger.debug("user_privilege.rb:setup_new_org - cannot find mobile session for user")
          end
          #Update the user privilege to reflect the organization update
          if @organization.secure_network
            #if the organization requires approval
            @key[:is_approved] = true
            @key[:is_admin] = true
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => @organization[:id])
            #@user.update_attributes(:access_key_count => @user.access_key_count + 1)
          else
            @key[:is_approved] = true
            @key[:is_admin] = true
            @user.update_attributes(:access_key_count => @user.access_key_count + 1, :active_org => @organization[:id])
          end
          @key.save

          if params[:organization][:profile_id].presence
            @image = Image.find(params[:organization][:profile_id])
            @image.update_attribute(:org_id, @organization[:id])
          end
        else
          return "!UserNotificationCounter"
        end
      else
        return "!UserPrivilege"
      end

      #Create welcome post
      @post = Post.new(
        :org_id => @organization[:id],
        :owner_id => @user[:id],
        :title => "Welcome to " + @organization[:name],
        :content => "You have successfully created a network. Please contact hello@myshyft.com for assistance.",
        :post_type => 1
      )
      if @post.basic_hello

      else
        return "!Post"
      end

      #Create location
      if @location = Location.create!(
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
      else
        return "!Location"
      end
      return @key
    end
  end

  def complete_setup(owner_id)
    transaction do
      if save
        # 1. Setup owner
        @key = UserPrivilege.new(:org_id => self[:id], :owner_id => owner_id)
        @mession = Mession.where(:user_id => owner_id, :is_active => true, :org_id => 0).last
        @mession.update_attribute(:org_id, self[:id])
        @key.create_key_for(true)
        # 2. Setup root user
        @key
      end
    end
  end

  def complete_web_setup(owner_id)
    if save
      # 1. Setup owner
      @key = UserPrivilege.new(:org_id => self[:id], :owner_id => owner_id)
      @key.create_key_for_web(true)
      # 2. Setup root user
      @key
    end
  end

end
