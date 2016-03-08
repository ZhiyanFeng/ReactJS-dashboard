class CreatePollResults < ActiveRecord::Migration
  def self.up
  	create_table :poll_results do |t|
  		t.integer 	:org_id
      t.integer 	:user_id, 				null: false
      t.integer 	:poll_id, 				null: false
      t.integer 	:question_count,	default: 0
      t.integer 	:score,						default: 0
      t.string  	:answer_key
      t.boolean		:passed,					default: false
      t.boolean		:is_valid,				default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :poll_results
  end
end
