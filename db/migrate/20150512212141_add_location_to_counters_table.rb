class AddLocationToCountersTable < ActiveRecord::Migration
  def self.up
  	add_column 			:user_notification_counters, 	:location_id,  			:integer
  end

  def self.down
  	remove_column 	:user_notification_counters, 	:location_id
  end
end
