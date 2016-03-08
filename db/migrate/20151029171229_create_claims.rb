class CreateClaims < ActiveRecord::Migration
  def up
    create_table :claims do |t|
    	t.integer				:user_id
    	t.integer				:referred_count_required_for_claim
    	t.string				:status
    	t.float					:claim_amount

    	t.timestamps
    end
  end

  def down
  	drop_table :claims
  end
end