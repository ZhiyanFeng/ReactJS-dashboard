class ChannelPushReport < ActiveRecord::Base
  attr_accessible :channel_id,
    :target_number,
    :attempted,
    :success,
    :failed_due_to_missing_id,
    :failed_due_to_other

end
