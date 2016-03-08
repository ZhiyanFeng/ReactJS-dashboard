class EngagementWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false
  
  def perform(location)
    #if user[:last_seen_at] > Time.now - 48.hours
    @users = UserPrivilege.where(:location_id => location, :is_valid => true, :is_approved => true)
    @users.each do |key|
    	#logger.info "Looking for user #{key[:owner_id]}."
    	user = User.find(key[:owner_id])
    	#logger.debug "Here's some info: #{hash.inspect}"
    	#logger.info "Comparing #{user[:last_seen_at]} with #{Time.now.utc}"
	    if user[:last_seen_at].present?
	    	if !user[:last_engaged_at].present?
		    	if user[:last_seen_at] < Time.now.utc - 60.seconds && user[:is_valid] == true
			    	#logger.info "Can do something about this user."
		    		#logger.debug "Here's some info: #{hash.inspect}"
			    	if Mession.exists?(:user_id => user[:id], :is_active => true, :is_valid => true)
			      	@mession = Mession.where(:user_id => user[:id], :is_active => true, :is_valid => true).first
			    		#logger.info "Did something about this user with mession id #{@mession[:id]}."
			    		subscription_list = Subscription.where(:user_id => user[:id], :is_valid => true, :is_active => true).pluck(:channel_id)
			    		count_posts = Post.where("created_at < '#{user[:last_seen_at]}' AND is_valid AND channel_id in (#{subscription_list.join(", ")})").count
			    		chat_session_list = ChatParticipant.where(:user_id => user[:id], :is_valid => true, :is_active => true).pluck(:session_id)
			    		count_chats = ChatMessage.where("created_at < '#{user[:last_seen_at]}' AND is_valid AND session_id in (#{chat_session_list.join(", ")})").count
			    		if count_posts > 0 && count_chats > 0
			      		message = "Your team miss you! You have #{count_posts} unread posts and #{count_chats} unread messages. Check them out!"
			      	elsif count_posts == 0
			      		message = "Your team miss you! You have #{count_message} unread messages. Check them out!"
			      	elsif count_chats == 0
			      		message = "Your team miss you! You have #{count_posts} unread posts. Check them out!"
			      	end
			        @mession.subscriber_push("open_app", message, 4, 1, nil, user)
			        user.update_attribute(:last_engaged_at, Time.now.utc)
			      end
			    end
			  else
			  	seen_factor = ((Time.now.utc - user[:last_seen_at]) / 1.hour).round #number of hours since last seen
			  	next_engage_factor = seen_factor / 2 #divide this hour number by 2
			  	engage_factor = ((Time.now.utc - user[:last_engaged_at]) / 1.hour).round #number of hours since last engagement
			  	#logger.info "SEEN: #{seen_factor} - NEXT_ENGAGE: #{next_engage_factor} - ENGAGE: #{engage_factor}"
			  	if engage_factor > next_engage_factor #when the last time we engaged is smaller than half the time ur not seen
			  		if Mession.exists?(:user_id => user[:id], :is_active => true, :is_valid => true)
			      	@mession = Mession.where(:user_id => user[:id], :is_active => true, :is_valid => true).first
			    		#logger.info "Did something about this user with mession id #{@mession[:id]}."
			      	subscription_list = Subscription.where(:user_id => user[:id], :is_valid => true, :is_active => true).pluck(:channel_id)
			    		count_posts = Post.where("created_at < '#{user[:last_seen_at]}' AND is_valid AND channel_id in (#{subscription_list.join(", ")})").count
			    		chat_session_list = ChatParticipant.where(:user_id => user[:id], :is_valid => true, :is_active => true).pluck(:session_id)
			    		count_chats = ChatMessage.where("created_at < '#{user[:last_seen_at]}' AND is_valid AND session_id in (#{chat_session_list.join(", ")})").count
			      	if count_posts > 0 && count_chats > 0
			      		message = "Your team miss you! You have #{count_posts} unread posts and #{count_chats} unread messages. Check them out!"
			      	elsif count_posts == 0
			      		message = "Your team miss you! You have #{count_message} unread messages. Check them out!"
			      	elsif count_chats == 0
			      		message = "Your team miss you! You have #{count_posts} unread posts. Check them out!"
			      	end
			        @mession.subscriber_push("open_app", message, 4, 1, nil, user)
			        user.update_attribute(:last_engaged_at, Time.now.utc)
			      end
			  	end
			  end
		  else
		  	user.update_attribute(:last_seen_at, Time.now.utc)
	    end
	  end
  end
end