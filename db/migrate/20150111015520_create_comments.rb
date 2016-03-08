class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
    	t.integer  :owner_id, 			null: false
      t.integer  :source, 				null: false
      t.integer  :source_id
      t.text     :content, 				null: false
      t.integer  :attachment_id
      t.integer  :comment_type,		default: 0
      t.integer  :likes_count, 		default: 0
      t.boolean  :is_flagged, 		default: false
      t.boolean  :is_valid, 			default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :comments
  end
end
