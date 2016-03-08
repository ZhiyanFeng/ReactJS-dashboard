class AdminPrivilege < ActiveRecord::Base
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"
  belongs_to :user, :class_name => "User", :foreign_key => "owner_id"
  belongs_to :location, :class_name => "Location", :foreign_key => "location_id"

  attr_accessible :owner_id,
    :org_id,
    :location_id,
    :master_key,
    :parent_key,
    :key_hash,
    :is_valid
  
  validates_presence_of :owner_id, :on => :create
  validates_presence_of :org_id, :on => :create
  validates_presence_of :location_id, :on => :create
  validates_uniqueness_of :owner_id, :scope => [:location_id]

  before_create :generate_key_hash

  def self.grant_system_access(user)
    @locations = Location.all
    @locations.each do |location|
      if !AdminPrivilege.exists?(:owner_id => user.id, :location_id => location.id)
        @key = AdminPrivilege.new(
          :owner_id => user.id,
          :org_id => location.org_id,
          :location_id => location.id
        )
        @key.save
      end
    end
  end

  def self.grant_location_access(user, location)
    if !AdminPrivilege.exists?(:owner_id => 134, :location_id => location)
      @key = AdminPrivilege.new(
        :owner_id => 134,
        :org_id => 1,
        :location_id => location
      )
      @key.save
    end
  end

  def copy(master)
    if master.master_key.present?
      self.master_key = master.master_key
    else
      self.master_key = master.id
    end
    self.parent_key = master.id
    self.save
  end

  def parent_recall
    @keys = AdminPrivilege.where(:parent_key => self.id)
    @keys.each do |key|
      key.update_attribute(:is_valid, false)
    end
  end

  def master_recall
    @keys = AdminPrivilege.where(:master_key => self.id)
    @keys.each do |key|
      key.update_attribute(:is_valid, false)
    end
  end

  def destroy
    @keys = AdminPrivilege.where("parent_key = ? OR master_key = ?", self.id, self.id)
    @keys.each do |key|
      key.update_attribute(:is_valid, false)
    end
  end

  private

  def generate_key_hash
    self.key_hash = SecureRandom.hex(24)
  end
end
