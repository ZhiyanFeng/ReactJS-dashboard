class AddChannelToPosts < ActiveRecord::Migration
  def self.up
  	add_column 			:posts, 	:channel_id, :integer
  end

  def self.down
  	remove_column 	:posts, 	:channel_id
  end
end
