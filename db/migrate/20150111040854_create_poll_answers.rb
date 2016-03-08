class CreatePollAnswers < ActiveRecord::Migration
  def self.up
  	create_table :poll_answers do |t|
      t.integer :question_id,		null: false
			t.text 		:content,				null: false
			t.boolean :correct, 			default: false
			t.boolean :is_active, 		default: true
			t.boolean :is_valid, 			default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :poll_answers
  end
end
