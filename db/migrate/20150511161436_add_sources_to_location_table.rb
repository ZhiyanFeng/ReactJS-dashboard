class AddSourcesToLocationTable < ActiveRecord::Migration
	def self.up
  	add_column 			:locations, 				:four_sq_id,		    :string
  	add_column 			:locations, 				:google_map_id,  		:string
  	add_column 			:user_privileges, 	:location_id,  			:integer
  end

  def self.down
  	remove_column 	:locations, 				:four_sq_id
  	remove_column 	:locations, 				:google_map_id
  	remove_column 	:user_privileges, 	:location_id
  end
end
