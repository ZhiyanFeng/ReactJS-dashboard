class AddStatusToShiftElement < ActiveRecord::Migration
  def self.up
  	add_column 			:schedule_elements, 		:trade_status,		:integer, :default => 0
  	add_column 			:schedule_elements, 		:coverer_id,  		:integer,	:default => nil
  end

  def self.down
  	remove_column 	:schedule_elements, 		:trade_status
  	remove_column 	:schedule_elements, 		:coverer_id
  end
end
