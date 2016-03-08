# == Schema Information
#
# Table name: chat_participants
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  session_id   :integer          not null
#  unread_count :integer          default(0)
#  is_active    :boolean          default(TRUE)
#  is_valid     :boolean          default(TRUE)
#  created_at   :timestamp
#  updated_at   :timestamp
#

class ChatParticipant < ActiveRecord::Base
	belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
	belongs_to :chat_session, :foreign_key => "session_id"

	attr_accessible :user_id, :session_id, :unread_count, :view_from, :is_active, :is_valid

	validates_presence_of :user_id, :on => :create
	validates_presence_of :session_id, :on => :create
	
	def reset_count
	  transaction do
	    #@user = User.find(self[:user_id])
  	  #@user.update_attribute(:push_count, @user[:push_count] - self[:unread_count])
  	  self.update_attribute(:unread_count, 0)
    end
  end
  
  def deactivate
	  @user.update_attribute(:push_count, @user[:push_count] - self[:unread_count])
	  self.update_attribute(:unread_count, 0)
    self.update_attribute(:is_active, false)
  end
end
