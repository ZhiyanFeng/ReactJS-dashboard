class AddPostIdToShift < ActiveRecord::Migration
  def self.up
    add_column        :schedule_elements,  :post_id, :integer
  end

  def self.down
    remove_column     :schedule_elements,  :post_id
  end
end
