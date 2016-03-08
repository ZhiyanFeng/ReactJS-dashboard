# == Schema Information
#
# Table name: chat_messages
#
#  id           :integer          not null, primary key
#  message      :text             not null
#  attachment   :integer
#  message_type :integer          default(0)
#  session_id   :integer          not null
#  sender_id    :integer          not null
#  is_active    :boolean          default(TRUE)
#  is_valid     :boolean          default(TRUE)
#  created_at   :timestamp
#  updated_at   :timestamp
#

class ChatMessage < ActiveRecord::Base
	belongs_to :chat_session, :foreign_key => "session_id"
	belongs_to :owner, :class_name => "User", :foreign_key => "sender_id"

	attr_accessible :message, :message_type, :session_id, :sender_id, :attachment_id, :is_active, :is_valid

	validates_presence_of :message, :on => :create
	validates_presence_of :session_id, :on => :create
	validates_presence_of :sender_id, :on => :create

	def my_logger
    @@chat_logger ||= Logger.new("#{Rails.root}/log/chat.log")
  end

  def before_save
    chat_logger.info("User #{self.sender_id} sent a message to #{self.session_id} on #{Time.now}")
  end

  def send_message
      if save
        @session = ChatSession.find(self.session_id)
        if self[:message_type] == 1 || self[:message].match(/^\[IMG\].+\[\/IMG\]$/)
          if User.exists?(:id => self[:sender_id])
            @sender = User.find(self[:sender_id])
            @session.update_attributes(:latest_message => "#{@sender[:first_name]} shared an image", :message_count => @session.message_count + 1)
          else
            @session.update_attributes(:latest_message => "An image has been shared.", :message_count => @session.message_count + 1)
          end
        elsif self[:message_type] == 2
          if User.exists?(:id => self[:sender_id])
            @sender = User.find(self[:sender_id])
            @session.update_attributes(:latest_message => "#{@sender[:first_name]} send a shift trade for approval", :message_count => @session.message_count + 1)
          else
            @session.update_attributes(:latest_message => "A shift trade approval is waiting for your approval.", :message_count => @session.message_count + 1)
          end
        else
          @session.update_attributes(:latest_message => self.message, :message_count => @session.message_count + 1)
        end
        #if Channel.exists?(:channel_type => "user_chat", :channel_frequency => self.session_id.to_s)
        #  @channel = Channel.where(:channel_type => "user_chat", :channel_frequency => self.session_id.to_s).first
        #  if self[:message].match(/^\[IMG\].+\[\/IMG\]$/)
        #    @channel.update_attributes(:channel_latest_content => "Sent you an image", :channel_content_count => @channel[:channel_content_count] + 1)
        #  else
        #    @channel.update_attributes(:channel_latest_content => self.message, :channel_content_count => @channel[:channel_content_count] + 1)
        #  end
        #end
        @session.reactivate_sender(self.sender_id)
        @session.notify_recipients(self.sender_id, self)
      end
  end
end
