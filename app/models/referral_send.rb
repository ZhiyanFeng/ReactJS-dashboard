class ReferralSend < ActiveRecord::Base
  attr_accessible	:sender_id,
  :program_code,
  :referral_link,
  :referral_platform,
  :referral_code,
  :referral_target_id

  after_create :post_invitation_engagement

  def post_invitation_engagement
    if self.referral_platform == "TWILIO"
      PostInviteWorker.perform_in(1.minutes, self[:id], 1)
      PostInviteWorker.perform_in(2.minutes, self[:id], 24)
      PostInviteWorker.perform_in(3.minutes, self[:id], 72)
    end
  end

end
