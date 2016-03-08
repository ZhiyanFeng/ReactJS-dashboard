class FlashMessageResponse < ActiveRecord::Base
  
  attr_accessible :user_id, :flash_message_uid, :clicked
end