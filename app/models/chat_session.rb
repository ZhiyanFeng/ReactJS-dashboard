# == Schema Information
#
# Table name: chat_sessions
#
#  id                :integer          not null, primary key
#  org_id            :integer          not null
#  message_count     :integer          default(0)
#  participant_count :integer          not null
#  latest_message    :text             default("")
#  is_active         :boolean          default(TRUE)
#  is_valid          :boolean          default(TRUE)
#  created_at        :timestamp
#  updated_at        :timestamp
#

class ChatSession < ActiveRecord::Base
	has_many :messages, :class_name => "ChatMessage", :foreign_key => "session_id"
	has_many :participants, :class_name => "ChatParticipant", :foreign_key => "session_id"

	attr_accessible :org_id, :message_count, :participant_count, :multiuser_chat,
	:latest_message, :is_active, :is_valid, :is_admin_session

	#validates_presence_of :org_id, :on => :create

  def setup_chat_subscription
    transaction do
      # the official coffee feed where everyone subscribes to
      if chat_channel = Channel.create(
          :channel_type => "user_chat",
          :channel_frequency => self[:id].to_s,
          :owner_id => 134,
          :channel_latest_content => self[:latest_message],
          :channel_content_count => self[:message_count],
          :is_valid => self[:is_valid],
          :is_active => self[:is_valid],
          :is_public => false
        )
        ChatParticipant.where(:session_id => self[:id]).each do |participant|
          Subscription.create(
            :user_id => participant[:user_id],
            :channel_id => chat_channel[:id],
            :is_valid => true
          )
        end
        chat_channel.recount
      end
    end
  end

  def self.session_exists(p1,p2,org)
		query = "SELECT session.id FROM chat_sessions AS session FULL JOIN chat_participants AS part1 ON session.id=part1.session_id FULL JOIN chat_participants AS part2 ON session.id=part2.session_id WHERE part1.user_id=#{p1} AND part2.user_id=#{p2} AND session.org_id=1 AND session.is_active AND session.is_valid AND multiuser_chat IS FALSE"

		connection = ActiveRecord::Base.connection()
		@session = connection.execute(query)

		if @session.first
			#UserAnalytic.create(:action => 3,:org_id => @mession[:org_id], :user_id => @user[:id], :ip_address => request.remote_ip.to_s)
			return @session.first.first[1].to_i
		else
			Rails.logger.debug("missing")
			return false
		end
	end

	def add_participants(list)
	  last_message = 0
	  if ChatMessage.exists?(:session_id => self[:id])
	    temp = ChatMessage.where(:session_id => self[:id]).order("id desc").first
	    last_message = temp[:id]
    end
	  list.split.each do |p|
	    @chat_participant = ChatParticipant.new(
				:session_id => self[:id],
				:user_id => p,
				:is_active => false, # build 1001: for chat sessions start off inactive unless someone send message
				:view_from => last_message
				)
			if @chat_participant.save
        self.update_attribute(:participant_count, self[:participant_count] + 1);
      end
    end
  end

	def create_session(participants)
	  transaction do
	    if save
	      participants.each do |user|
    			@chat_participant = ChatParticipant.new(
    				:session_id => self[:id],
    				:user_id => user[:id],
    				:is_active => false # build 1001: for chat sessions start off inactive unless someone send message
    				)
    			@chat_participant.save
    		end
    		self.update_attributes(:multiuser_chat => false)
    	end
      #self.setup_chat_subscription
		end
  end

  def create_multiuser_session(host, participants)
    transaction do
	    if save
	      participants.each do |user|
    			@chat_participant = ChatParticipant.new(
    				:session_id => self[:id],
    				:user_id => user[:id],
    				:is_active => false, # build 1001: for chat sessions start off inactive unless someone send message
    				:view_from => 0
    				)
    			@chat_participant.save
    		end
    		self.update_attributes(:multiuser_chat => true)
    	end

		end
  end

  def reactivate_sender(sender_id)
    begin
      @sender = ChatParticipant.where(['session_id=? AND user_id=?', self[:id], sender_id])
  		@sender.first.update_attributes(:is_active => true, :is_valid => true)
		  true
  	rescue
  	  -1
    ensure

    end
  end

  def notify_recipients(sender_id, message)
    @sender = User.find(sender_id)
		#@sender.update_attribute(:push_count, @sender.push_count + 1)
    @participants = ChatParticipant.where(['session_id=? AND user_id!=? AND is_valid', self[:id], sender_id])
		@participants.each do |p|
  		begin
			  @user = User.find(p[:user_id])
			  @user.update_attribute(:push_count, @user[:push_count] + 1)
        #V3 - @mession = Mession.where(:user_id => p[:user_id], :is_active => true, :org_id => self[:org_id]).last
        @mession = Mession.where(:user_id => p[:user_id], :is_active => true).last
			  p.update_attributes(:unread_count => p.unread_count + 1, :is_active => true)
        send_this_message = message.message
        if message[:message].match(/^\[IMG\].+\[\/IMG\]$/)
          send_this_message = "shared an image"
        end
        if @mession && @mession[:push_to] == "APNS"
          alert = @sender[:first_name] + " " + @sender[:last_name] + ": " + send_this_message
          push_to("APNS", @mession[:push_id], alert, self[:id], @sender, @user[:push_count])
        elsif @mession && @mession[:push_to] == "GCM"
          push_to("GCM", @mession[:push_id], send_this_message, self[:id], @sender, @user[:push_count], message.id, message.created_at)
        end
		  rescue
  	  ensure
      end
    end
  end

  def push_to(service, token, message, session_id, sender, badge, id=nil, created_at=nil)
    if service == "APNS"
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
      n.device_token = token
      n.alert = message.truncate(50)
      n.badge = badge
      n.sound = "default"
      #n.attributes_for_device
      n.data = {
        :cat => "chat",
        :oid => sender[:active_org],
        :sid => session_id,
        :sdr => sender[:first_name] + " " + sender[:last_name],
        :chd => sender[:chat_handle]
      }
      n.save!
    elsif service == "GCM"
      begin
        n = Rpush::Gcm::Notification.new
        n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
        n.registration_ids = token
        #n.attributes_for_device =
        n.data = {
          :cat => "chat",
          :oid => sender[:active_org],
          :sid => session_id,
          :sdr => sender[:first_name] + " " + sender[:last_name],
          :chd => sender[:chat_handle],
          :mid => id,
          :message => message,
          :msg => message
        }
        n.save!
      rescue => e
        ErrorLog.create(
          :file => "chat_session.rb",
          :function => "push_to",
          :error => "GCM push notification not getting created. #{e}")
      end
    end
  end
end
