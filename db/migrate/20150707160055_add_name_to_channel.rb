class AddNameToChannel < ActiveRecord::Migration
  def self.up
  	add_column 			:channels, 	:channel_name, 	:string
  end

  def self.down
  	remove_column 	:channels, 	:channel_name
  end
end
