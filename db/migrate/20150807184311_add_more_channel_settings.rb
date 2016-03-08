class AddMoreChannelSettings < ActiveRecord::Migration
  def self.up
  	add_column 			:channels, 	:allow_shift_trade, 	:boolean, :default => true
  	add_column 			:channels, 	:allow_schedule, 			:boolean, :default => true
  	add_column 			:channels, 	:allow_announcement, 	:boolean, :default => true
  end

  def self.down
  	remove_column 	:channels, 	:allow_shift_trade
  	remove_column 	:channels, 	:allow_schedule
  	remove_column 	:channels, 	:allow_announcement
  end
end
