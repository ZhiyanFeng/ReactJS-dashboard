class AddAllowToPostsTable < ActiveRecord::Migration
  def self.up
  	add_column 			:posts, 	:allow_comment, :boolean, :default => true
  	add_column 			:posts, 	:allow_like, :boolean, :default => true
  	add_column 			:posts, 	:z_index, :integer, :default => 0
  end

  def self.down
  	remove_column 	:posts, 	:allow_comment
  	remove_column 	:posts, 	:allow_like
  	remove_column 	:posts, 	:z_index
  end
end
