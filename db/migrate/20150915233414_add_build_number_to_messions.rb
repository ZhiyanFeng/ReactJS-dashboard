class AddBuildNumberToMessions < ActiveRecord::Migration
  def self.up
    add_column	 			:messions, 							:build, 										:string
    add_column 				:users, 	              :last_seen_at, 	            :datetime
    add_column 				:users, 	              :last_engaged_at, 	        :datetime
  end

  def self.down
  	remove_column 		:messions, 							:build
  	remove_column 		:users, 								:last_seen_at
  	remove_column 		:users, 								:last_engaged_at
  end
end
