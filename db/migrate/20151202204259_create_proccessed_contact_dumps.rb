class CreateProccessedContactDumps < ActiveRecord::Migration
  def up
    create_table 		:processed_contact_dumps do |t|
    	t.string  		:phone_number
    	t.integer			:user_reference_count
    	t.text  			:referenced_user_ids
    	t.integer			:location_reference_count
    	t.text  			:referenced_location_ids
    	t.integer			:lead_score
      t.string  		:first_name
      t.string  		:last_name
      t.text  			:emails
      t.text  			:social_links

    	t.timestamps
    end
  end

  def down
  	drop_table :processed_contact_dumps
  end
end
