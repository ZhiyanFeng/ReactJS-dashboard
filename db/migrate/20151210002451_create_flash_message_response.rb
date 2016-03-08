class CreateFlashMessageResponse < ActiveRecord::Migration
	def up
    create_table 		:flash_message_responses do |t|
    	t.integer			:user_id
    	t.text  			:flash_message_uid
    	t.boolean			:clicked

    	t.timestamps
    end
  end

  def down
  	drop_table :flash_message_responses
  end
end
