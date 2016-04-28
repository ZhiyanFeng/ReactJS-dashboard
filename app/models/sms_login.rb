class SmsLogin < ActiveRecord::Base
  attr_accessible :user_id, :validation_code, :validation_entered, :is_used, :is_valid
end
