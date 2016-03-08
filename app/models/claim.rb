class Claim < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  attr_accessible :user_id, 
  :referred_count_required_for_claim, 
  :status, 
  :claim_id,
  :claim_amount,
  :email,
  :verification_code,
  :verified

  before_create :generate_verification_code, :generate_claim_id

  def generate_verification_code
    begin
      #self[:invite_code] = SecureRandom.urlsafe_base64
      if Rails.env.production?
        self[:verification_code] = 999 + Random.rand(10000-1000)
      else
        self[:verification_code] = 9999
      end
    end
  end

  def generate_claim_id
  	self[:claim_id] = SecureRandom.hex
  end
end