class CreateChatSessions < ActiveRecord::Migration
  def self.up
    create_table :chat_sessions do |t|
      t.integer :org_id,              null: false
      t.integer :message_count,       default: 0
      t.integer :participant_count,   default: 0
      t.text    :latest_message
    	t.boolean :multiuser_chat, 			default: false
			t.boolean :is_active, 		      default: true
			t.boolean :is_valid, 			      default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :chat_sessions
  end
end
