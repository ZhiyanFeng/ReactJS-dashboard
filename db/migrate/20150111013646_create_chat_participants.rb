class CreateChatParticipants < ActiveRecord::Migration
  def self.up
    create_table :chat_participants do |t|
    	t.integer :user_id, 			null: false
			t.integer :session_id, 		null: false
			t.integer :unread_count, 	default: 0
      t.integer :view_from,     default: 0
			t.boolean :is_active, 		default: true
			t.boolean :is_valid, 			default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :chat_participants
  end
end
