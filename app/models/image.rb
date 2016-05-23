# == Schema Information
#
# Table name: images
#
#  id                  :integer          not null, primary key
#  org_id              :integer          not null
#  owner_id            :integer          not null
#  comments_count      :integer          default(0)
#  likes_count         :integer          default(0)
#  image_type          :integer
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer
#  avatar_updated_at   :timestamp
#  is_valid            :boolean          default(TRUE)
#  created_at          :timestamp
#  updated_at          :timestamp
#

class Image < ActiveRecord::Base
  belongs_to :settings, :class_name => "ImageType", :foreign_key => "image_type"
  belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :gallery_image, :foreign_key => "owner_id"
  #belongs_to :profile_image, :class_name => "User", :foreign_key => "profile_id"
  #has_many :comments, -> { where ['comments.source = 4 AND comments.is_valid'] }, :class_name => "Comment", :foreign_key => "source_id"
  has_many :comments, -> { where ['comments.source = 3 AND comments.is_valid'] }, :class_name => "Comment", :foreign_key => "source_id"
  has_many :likes, -> { where ['likes.source = 3'] }, :foreign_key => "source_id"
  has_many :users, :through => :likes
  has_many :flags, -> { where ['flags.source = 3'] }, :foreign_key => "source_id"
  has_many :users, :through => :flags

  attr_accessor :liked, :flagged, :user_id

  attr_accessible :org_id, :owner_id, :comments_count,
  :likes_count, :image_type, :avatar_file_name, :avatar_content_type,
  :avatar_file_size, :avatar_updated_at, :is_valid, :avatar

  attr_reader :avatar_remote_url

  has_attached_file :avatar,
  :styles => { thumb: '192x192#', gallery: '400x300#', full: '720x405>' }

  #validates_presence_of :org_id, :on => :create
  validates_presence_of :owner_id, :on => :create
  #validates_presence_of :image_type, :on => :create

  def check_user(id)
    self.user_id = id
  end

  def thumb_url
    avatar.url(:thumb)
  end

  def gallery_url
    avatar.url(:gallery)
  end

  def full_url
    avatar.url(:full)
  end

  def avatar_remote_url=(url_value)
    self.avatar = URI.parse(url_value)
    @avatar_remote_url = url_value
  end

  def upload_image_for_user(file, reference)
    transaction do
      if save
        if User.exists?(:id => self.owner_id)
          @user = User.find(self.owner_id)
          self.update_attributes(:image_type => Image.reference_by_description(reference))
          self.update_attribute(:avatar, file)
          self.update_attribute(:is_valid, true)
          @user.update_attribute(:profile_id, self.id) if reference == "user_profile"
          @user.update_attribute(:cover_id, self.id) if reference == "user_cover"
        else
          errors[:base] << "Could not find User with id=" + self.owner_id
          return false
        end
      end
    end
  end

  def upload_image_for_organization(file, reference)
    transaction do
      if save
        if Organization.exists?(:id => self.org_id)
          @organization = Organization.find(self.org_id)
          self.update_attributes(:image_type => Image.reference_by_description(reference))
          self.update_attribute(:avatar, file)
          self.update_attribute(:is_valid, true)
          @organization.update_attribute(:profile_id, self.id) if reference == "org_profile"
          @organization.update_attribute(:cover_id, self.id) if reference == "org_cover"
        else
          errors[:base] << "Could not find Organization with id=" + self.org_id
          return false
        end
      end
    end
  end

  def create_upload_and_set_organization_profile(org, file)
    transaction do
      if save
        self.update_attribute(:image_type, 1)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
        if Organization.exists?(:id => org)
          @organization = Organization.find(org)
          @organization.update_attribute(:profile_id, self.id)
        end
      end
    end
  end

  def create_and_upload_organization_cover_image(org, file)
    transaction do
      if save
        self.update_attribute(:image_type, 5)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
        if Organization.exists?(:id => org)
          @organization = Organization.find(owner)
          @organization.update_attribute(:cover_id, self.id)
        end
      end
    end
  end

  def create_upload_and_set_organization_profile_android(file)
    transaction do
      if save
        self.update_attribute(:image_type, 1)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
      end
    end
  end

  def create_upload_and_set_channel_profile(owner, file, channel_id)
    transaction do
      if save
        self.update_attribute(:image_type, 2)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
        if Channel.exists?(:id => channel_id)
          @channel = Channel.find(channel_id)
          @channel.update_attribute(:profile_id, self.id)
        end
      end
    end
  end

  def create_upload_and_set_user_profile(owner, file)
    transaction do
      if save
        self.update_attribute(:image_type, 2)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
        if User.exists?(:id => owner)
          @user = User.find(owner)
          @user.update_attribute(:profile_id, self.id)
        end
      end
    end
  end

  def create_and_upload_user_cover_image(owner, file)
    transaction do
      if save
        self.update_attribute(:image_type, 5)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
        if User.exists?(:id => owner)
          @user = User.find(owner)
          @user.update_attribute(:cover_id, self.id)
        end
      end
    end
  end

  def create_and_upload_post_image(file)
    transaction do
      if save
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
      end
    end
  end

  #def create_and_upload_user_gallery_image(file)
  #  transaction do
  #    if save
  #      self.update_attribute(:image_type, 6)
  #      self.update_attribute(:avatar, file)
  #      self.update_attribute(:is_valid, true)
  #    end
  #  end
  #end

  def create_and_upload_newsfeed_image(file)
    transaction do
      if save
        self.update_attribute(:image_type, 4)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
      end
    end
  end

  def create_and_upload_announcement_image(file)
    transaction do
      if save
        self.update_attribute(:image_type, 3)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
      end
    end
  end

  def create_and_upload(file)
    transaction do
      if save
        self.update_attribute(:image_type, 4)
        self.update_attribute(:avatar, file)
        self.update_attribute(:is_valid, true)
      end
    end
  end
end
