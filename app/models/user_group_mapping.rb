class UserGroupMapping < ActiveRecord::Base
  attr_accessible :org_id, :user_id, :group_id, :is_valid

  validates_uniqueness_of :user_id, :scope => [:org_id, :group_id]

  before_destroy :invalidate_mapping

  def invalidate_mapping
    self.is_valid = false
    self.save
  end
end