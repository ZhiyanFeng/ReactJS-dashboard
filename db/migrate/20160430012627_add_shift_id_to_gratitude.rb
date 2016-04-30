class AddShiftIdToGratitude < ActiveRecord::Migration
  def self.up
    add_column        :gratitudes,  :shift_id, :integer
  end

  def self.down
    remove_column     :gratitudes,  :shift_id
  end
end
