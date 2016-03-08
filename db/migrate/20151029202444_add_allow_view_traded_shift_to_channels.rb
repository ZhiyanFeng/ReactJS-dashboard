class AddAllowViewTradedShiftToChannels < ActiveRecord::Migration
  def self.up
    add_column 				:channels,	:allow_view_covered_shifts,	:boolean, :default => false
  end

  def self.down
  	remove_column 		:channels,	:allow_view_covered_shifts
  end
end
