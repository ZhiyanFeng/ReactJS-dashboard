class CreateMessions < ActiveRecord::Migration
  def self.up
    create_table :messions do |t|
    	t.integer  	:org_id
    	t.integer  	:user_id, 						null: false
      t.string   	:device, 							null: false
      t.string   	:device_id, 					null: false
      t.string   	:ip_address
      t.timestamp :start
      t.string   	:start_location
      t.timestamp :finish
      t.string   	:finish_location
      t.string   	:push_to, 						null: false
      t.string   	:push_id
      t.string   	:session_id
      t.boolean  	:is_active, 					default: true
			t.boolean  	:is_valid,						default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :messions
  end
end
