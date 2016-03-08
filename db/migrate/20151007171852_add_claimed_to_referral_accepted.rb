class AddClaimedToReferralAccepted < ActiveRecord::Migration
  def self.up
    add_column 				:referral_accepts,	:claimed,	:boolean, :default => false
  end

  def self.down
  	remove_column 		:referral_accepts,	:claimed
  end
end
