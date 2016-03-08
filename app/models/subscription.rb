class Subscription < ActiveRecord::Base

  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :channel, :class_name => "Channel", :foreign_key => "channel_id"

  attr_accessor :params_sync_fresh, :params_sync_time, :params_sync_new

  attr_accessible :user_id,
  :channel_id,
  :subscription_nickname,
  :subscription_my_alias,
  :subscription_stick_to_top,
  :subscription_mute_notifications,
  :subscription_display_nicknames,
  :subscription_last_synchronize,
  :is_admin,
  :is_coffee,
  :is_invisible,
  :is_active,
  :is_valid

  validates_uniqueness_of :user_id, :scope => [:channel_id]

  def notify_removed(channel)
    user = User.find(self[:user_id])
    if channel[:channel_type] == "location_feed"
      message = "You have been removed from the #{channel[:channel_name]} channel."
    else
      message = "You have been removed from the #{channel[:channel_name]} channel."
    end
    if Mession.exists?(:user_id => self[:user_id], :is_valid => true, :is_active => true)
      @mession = Mession.where(:user_id => self[:user_id], :is_valid => true, :is_active => true).first
      @mession.subscriber_push("open_app", message, 4, 11412, true, user)
    end
  end

  def check_parameters(time, new_subscription, fresh)
    #Rails.logger.debug("TIME: #{time}, NEW: #{new_subscription}, FRESH: #{fresh}")
    self.params_sync_time = time
    self.params_sync_new = new_subscription
    self.params_sync_fresh = fresh
  end

  def change_subscription_nickname(nickname)
    self.subscription_nickname = nickname
  end

  def change_alias(new_alias)
    self.subscription_my_alias = new_alias
  end

  def set_stick_to_top
    self.subscription_stick_to_top = true
  end

  def set_do_not_stick_to_top
    self.subscription_stick_to_top = false
  end

  def mute_feed
    self.subscription_mute_notifications = true
  end

  def unmute_feed
    self.subscription_mute_notifications = false
  end

end
