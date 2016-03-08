class CreatePolls < ActiveRecord::Migration
  def self.up
  	create_table :polls do |t|
  		t.integer 	:org_id, 					null: false
      t.integer 	:owner_id, 				null: false
      t.string		:poll_name,				null: false
      t.integer 	:complete_count, 	default: 0
      t.integer		:question_count,	default: 0
      t.integer		:count_down,			default: 10
      t.integer		:pass_mark,				default: 0
      t.integer		:attempts_count,	default: 0
      t.timestamp :start_at
      t.timestamp :end_at
			t.boolean 	:is_active, 			default: true
			t.boolean 	:is_valid, 				default: true
			
      t.timestamps	
    end
  end

  def self.down
  	drop_table :polls
  end
end
