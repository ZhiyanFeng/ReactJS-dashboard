class UserGroup < ActiveRecord::Base
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"
  belongs_to :avatar_image, :class_name => "Image", :foreign_key => "profile_id"

  attr_accessible :org_id, :owner_id, :group_name, :group_description, :group_avatar_id, :member_count, :is_valid

  def member_add
      self.update_attribute(:member_count, self.member_count + 1)
      self.save
  end


  def member_minus
  	if self.member_count <= 0
  	  count = User.where(:active_org => self.org_id, :user_group => self.id).count
  	  self.update_attribute(:member_count, count - 1)
  	else
      self.update_attribute(:member_count, self.member_count - 1)
      self.save
  	end
  end

  def destroy_this
    transaction do
      User.where(:user_group => self.id).update_all(:user_group => 0)
      self.update_attribute(:is_valid, false)
    end
  end

end
