class CreateChatMessages < ActiveRecord::Migration
  def self.up
    create_table :chat_messages do |t|
    	t.text    	:message, 				null:false
      t.integer 	:attachment_id
			t.integer 	:message_type, 		null: false, default: 0
			t.integer 	:session_id, 			null: false
			t.integer 	:sender_id, 			null: false
			t.boolean 	:is_active, 			default: true
			t.boolean 	:is_valid, 				default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :chat_messages
  end
end
