class SyncSystemSubscriptionSerializer < ActiveModel::Serializer

  attributes :id,
  :user_id,
  #:user,
  :is_admin,
  :channel_id,
  :channel,
  :subscription_nickname, 
  :subscription_my_alias, 
  :subscription_stick_to_top, 
  :subscription_mute_notifications, 
  :subscription_display_nicknames,
  :content_since_last_refresh,
  :is_valid,
  :is_active
  #:contents

  #def user
  #  OwnerSerializer.new(object.user)
  #end

  def is_admin
    if object.channel.channel_type.include? "location_feed"
      begin
        @priv = UserPrivilege.where(:location_id => object.channel.channel_frequency.to_i, :owner_id => object.user_id, :is_valid => true).first
        @priv[:is_admin]
      rescue
        #TBD
      ensure
        #TBD
      end
    else
      false
    end
  end

  def channel
    SystemUserChannelSerializer.new(object)
  end

  def content_since_last_refresh
    @post = Post.where("channel_id = #{object.channel_id} AND post_type IN (5,6,7,8,9,1,2,3,4,10) AND owner_id != #{user_id} AND created_at > TIMESTAMP '#{object.params_sync_time}' AND is_valid")
    @post.count
  end
  
end
