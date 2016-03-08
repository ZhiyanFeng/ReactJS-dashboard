class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
    	t.integer  :org_id, 							null: false
      t.integer  :owner_id, 						null: false
      t.integer  :comments_count, 			default: 0
      t.integer  :likes_count, 					default: 0
      t.integer  :viewss_count, 				default: 0
      t.integer  :image_type
      t.string   :avatar_file_name
      t.string   :avatar_content_type
      t.integer  :avatar_file_size
      t.datetime :avatar_updated_at
			t.boolean  :is_valid, 						default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :images
  end
end
