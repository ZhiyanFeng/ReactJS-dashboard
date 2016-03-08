class AddPrivacyToLocations < ActiveRecord::Migration
  def self.up
  	add_column 			:locations, 	:require_approval, 	:boolean, :default => false
  end

  def self.down
  	remove_column 	:locations, 	:require_approval
  end
end
