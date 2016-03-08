class WhitelistedDomain < ActiveRecord::Base
  self.primary_key = :id
  attr_accessible :org_id, :domain, :is_valid

  validates_presence_of :org_id, :on => :create
  validates_presence_of :domain, :on => :create
	validates_uniqueness_of :domain

  def create_flag(post_id)
    if Post.exists?(:id => post_id)
      @post = Post.find(post_id)
      transaction do
        if save
          
        end
      end
    else
      errors[:base] << "Couldn't find Post with id=" + post_id
      return false
    end
  end
  
  def destroy_flag
    self.update_attribute(:is_valid, false)
    if Post.exists?(:id => self.post_reference)
      @post = Post.find(self.post_reference)
      @post.decrease_flag
    end
  end
  
end
