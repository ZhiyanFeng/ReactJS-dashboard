class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
    	t.integer 	:org_id
      t.integer 	:owner_id, 						null: false, default: 0
    	t.string  	:email,								null: false, unique: true
      t.string  	:phone_number
      t.string  	:first_name
      t.string  	:last_name
      t.integer 	:location, 						default: 0
      t.integer 	:user_group, 					default: 0
      t.integer 	:profile_id
      t.string		:step,								limit: 32
      t.string		:invite_code,					null: false, limit: 64
      t.string  	:invite_url,					null: false, limit: 64
      t.boolean 	:is_invited,					default: false
      t.boolean 	:is_whitelisted,			default: false
			t.boolean 	:is_valid, 						default: true
			t.timestamp :valid_until

			t.timestamps
    end
  end

  def self.down
  	drop_table :invitations
  end
end
