class CreateImageTypes < ActiveRecord::Migration
  def self.up
    create_table :image_types do |t|
    	t.string 		:base_type
      t.string 		:description
      t.boolean 	:allow_comments
      t.boolean 	:allow_likes
      t.boolean 	:allow_flags
      t.boolean 	:allow_delete
      t.boolean 	:allow_enlarge
			t.boolean 	:is_valid, 					default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :image_types
  end
end
