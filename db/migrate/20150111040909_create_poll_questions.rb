class CreatePollQuestions < ActiveRecord::Migration
  def self.up
  	create_table :poll_questions do |t|
      t.integer 	:poll_id
      t.integer 	:attachment_id
			t.text 			:content, 				null: false
			t.string 		:question_type, 	default: 0
      t.integer 	:complete_count, 	default: 0
      t.boolean 	:randomize, 			default: true
			t.boolean 	:is_active, 			default: true
			t.boolean 	:is_valid, 				default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :poll_questions
  end
end
