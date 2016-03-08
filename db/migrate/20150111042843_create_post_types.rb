class CreatePostTypes < ActiveRecord::Migration
  def self.up
  	create_table :post_types do |t|
  		t.string 		:base_type
      t.string 		:description
      t.integer 	:image_count, 							limit: 2
      t.boolean 	:includes_video, 						default: false
      t.boolean 	:includes_event, 						default: false
      t.boolean 	:includes_survey, 					default: false
      t.boolean 	:includes_shift, 						default: false
      t.string 		:includes_layover, 					default: false
      t.boolean 	:includes_schedule, 				default: false
      t.boolean 	:includes_audio, 						default: false
      t.boolean 	:includes_url, 							default: false
      t.boolean 	:includes_pdf, 							default: false
      t.boolean 	:includes_safety_course, 		default: false
      t.boolean 	:allow_comments, 						default: true
      t.boolean 	:allow_likes, 							default: true
      t.boolean 	:allow_flags, 							default: true
      t.boolean 	:allow_delete, 							default: true
			t.boolean 	:is_valid, 									default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :post_types
  end
end
