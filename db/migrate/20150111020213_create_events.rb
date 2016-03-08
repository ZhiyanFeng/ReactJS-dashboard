class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
    	t.integer  		:org_id, 						null: false
      t.integer  		:owner_id, 					null: false
      t.timestamp 	:event_start, 			null: false
      t.timestamp 	:event_end
      t.string			:event_poi
      t.string   		:event_address, 		null: false
      t.string   		:event_lat, 				null: false, limit: 64
      t.string   		:event_lng, 				null: false, limit: 64
      t.boolean  		:event_open, 				default: true
			t.boolean  		:is_valid, 					default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :events
  end
end
