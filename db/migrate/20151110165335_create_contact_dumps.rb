class CreateContactDumps < ActiveRecord::Migration
  def up
    create_table :contact_dumps do |t|
    	t.integer   :user_id
    	t.text  		:phone_numbers
      t.text  		:first_name
      t.text  		:last_name
      t.text  		:emails
      t.text  		:social_links
      t.boolean 	:processed, 			default: false

    	t.timestamps
    end
  end

  def down
  	drop_table :contact_dumps
  end
end
