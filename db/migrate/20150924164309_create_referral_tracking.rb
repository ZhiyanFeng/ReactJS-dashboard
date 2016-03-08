class CreateReferralTracking < ActiveRecord::Migration
  def up
    create_table :referral_sends do |t|
    	t.integer				:sender_id
    	t.string				:program_code
    	t.string				:referral_link
    	t.string				:referral_platform
    	t.string				:referral_code
    	t.string				:referral_target_id

    	t.timestamps
    end

    create_table :referral_accepts do |t|
    	t.integer				:acceptor_id
    	t.string				:acceptor_branch_id
    	t.string				:program_code
    	t.string				:referral_platform
    	t.string				:referral_code
    	t.integer				:referral_credit_given

    	t.timestamps
    end
  end

  def down
    drop_table :referral_sends
    drop_table :referral_accepts
  end
end
