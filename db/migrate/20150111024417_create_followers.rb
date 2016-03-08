class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers do |t|
    	t.integer  :source, 		null: false
      t.integer  :source_id, 	null: false
      t.integer  :user_id, 		null: false
      t.boolean  :is_valid, 	default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :followers
  end
end
