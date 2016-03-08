class CreatePosts < ActiveRecord::Migration
  def self.up
  	create_table :posts do |t|
  		t.integer  :org_id, 				null: false
      t.integer  :owner_id, 			null: false
      t.string   :title, 					null: false
      t.text     :content
      t.integer  :attachment_id
      t.integer  :post_type
      t.integer  :comments_count, default: 0
      t.integer  :likes_count, 		default: 0
      t.integer  :views_count, 		default: 0
      t.integer  :location,		 		default: 0
      t.integer  :user_group, 		default: 0
      t.boolean  :is_flagged, 		default: false
			t.boolean  :is_valid, 			default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :posts
  end
end
