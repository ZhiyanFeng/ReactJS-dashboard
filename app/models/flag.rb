# == Schema Information
#
# Table name: flags
#
#  id         :integer          not null, primary key
#  owner_id   :integer          not null
#  source     :integer          not null
#  source_id  :integer          not null
#  is_valid   :boolean          default(TRUE)
#  created_at :timestamp
#  updated_at :timestamp
#

class Flag < ActiveRecord::Base
  belongs_to :posts
  belongs_to :users
  
  attr_accessible :owner_id, :source, :source_id

  validates_presence_of :owner_id, :on => :create
  validates_presence_of :source, :on => :create
  validates_presence_of :source_id, :on => :create
	validates_uniqueness_of :owner_id, :scope => [:source, :source_id]

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
