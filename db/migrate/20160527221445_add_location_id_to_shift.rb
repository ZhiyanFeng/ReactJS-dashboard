class AddLocationIdToShift < ActiveRecord::Migration
  def self.up
    add_column        :schedule_elements,  :location_id, :integer
  end

  def self.down
    remove_column     :schedule_elements,  :location_id
  end
end
