class AddViewProfileToChannels < ActiveRecord::Migration
  def self.up
  	add_column 			:channels, 	:allow_view_profile, 	:boolean, :default => true
  end

  def self.down
  	remove_column 	:channels, 	:allow_view_profile
  end
end
