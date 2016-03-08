class AddCountersToUsers < ActiveRecord::Migration
  def self.up
  	add_column 			:users, 	:shift_count, 		:integer, 	:default => 0
  	add_column 			:users, 	:cover_count, 		:integer, 	:default => 0
  	add_column 			:users, 	:shyft_score, 		:integer, 	:default => 0
    add_column      :users,   :last_recount,    :timestamp
  end

  def self.down
  	remove_column 	:users, 	:shift_count
  	remove_column 	:users, 	:cover_count
  	remove_column 	:users, 	:shyft_score
    remove_column   :users,   :last_recount
  end
end
