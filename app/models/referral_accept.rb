class ReferralAccept < ActiveRecord::Base
	belongs_to :acceptor, :class_name => "User", :foreign_key => "acceptor_id"

  attr_accessible	:acceptor_id,
  :acceptor_branch_id, 
  :program_code,
  :referral_platform,
  :referral_code,
  :referral_credit_given,
  :claimed

end