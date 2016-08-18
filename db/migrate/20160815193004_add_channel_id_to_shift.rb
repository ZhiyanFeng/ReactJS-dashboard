class AddChannelIdToShift < ActiveRecord::Migration
  def self.up
    add_column        :schedule_elements,  :channel_id, :integer
  end

  def self.down
    remove_column     :schedule_elements,  :channel_id
  end
end
