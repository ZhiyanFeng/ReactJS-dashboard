class AddCategoryToLocations < ActiveRecord::Migration
  def self.up
  	add_column 			:locations, 	:category, 		:string
  end

  def self.down
  	remove_column 	:locations, 	:category
  end
end
