# == Schema Information
#
# Table name: notifications
#
#  id           :integer          not null, primary key
#  notify_id    :integer          not null
#  sender_id    :integer          not null
#  recipient_id :integer
#  org_id       :integer
#  source       :integer          not null
#  source_id    :integer          not null
#  viewed       :boolean          default(FALSE)
#  event        :string(255)      not null
#  created_at   :timestamp
#  updated_at   :timestamp
#  message      :string(255)
#

class Notification < ActiveRecord::Base
	#belongs_to :notify_id, :class_name => "Notification", :foreign_key =>
	belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
	belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"

	attr_accessible :notify_id, :sender_id, :recipient_id, :source, :source_id, :event, :viewed, :message, :org_id, :is_valid

	validates_presence_of :source, :on => :create
	validates_presence_of :source_id, :on => :create
	validates_presence_of :sender_id, :on => :create
	validates_presence_of :org_id, :on => :create
	validates_presence_of :recipient_id, :on => :create
	validates_presence_of :message, :on => :create

	def self.did_view(user_id, source, source_id)
	  @notifications = Notification.where(:notify_id => user_id, :source => source, :source_id => source_id)
	  begin
	    @notifications.each do |p|
	      p.update(:viewed => true)
      end
    rescue
    ensure
    end

    return @notifications.count
  end
end
