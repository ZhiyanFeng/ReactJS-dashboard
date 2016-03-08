class ReferralSend < ActiveRecord::Base
  attr_accessible	:sender_id,
  :program_code, 
  :referral_link,
  :referral_platform,
  :referral_code,
  :referral_target_id

end