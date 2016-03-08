# == Schema Information
#
# Table name: user_privileges
#
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

class UserAnalytic < ActiveRecord::Base
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  attr_accessible :user_id,
    :action,
    :org_id,
    :length,
    :source,
    :source_id,
    :ip_address
  
  validates_presence_of :user_id, :on => :create
  validates_presence_of :org_id, :on => :create
  
  #before_save :set_ip
  
  private

  def set_ip
    self.ip_address = request.remote_ip.to_s;
  end 
end
