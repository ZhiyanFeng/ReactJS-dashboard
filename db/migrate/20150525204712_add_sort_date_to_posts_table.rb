class AddSortDateToPostsTable < ActiveRecord::Migration
  def self.up
  	add_column 	:posts, 	:sorted_at, 	:timestamp

  	# Set the value of the sorted_at column to the value of the record's created_at column
  	execute('UPDATE posts SET sorted_at=created_at')

  end

  def self.down
  	remove_column 	:posts, 	:sorted_at
  end
end
