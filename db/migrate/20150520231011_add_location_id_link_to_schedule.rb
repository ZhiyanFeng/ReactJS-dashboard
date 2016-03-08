class AddLocationIdLinkToSchedule < ActiveRecord::Migration
  def self.up
  	add_column 			:schedules, 	:location_id,  			:integer
  	add_column 			:schedules, 	:snapshot_url,  		:string
  end

  def self.down
  	remove_column 	:schedules, 	:location_id
  	remove_column 	:schedules, 	:snapshot_url
  end
end
