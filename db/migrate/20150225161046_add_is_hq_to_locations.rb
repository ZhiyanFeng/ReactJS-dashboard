class AddIsHqToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :is_hq, :boolean, :default => false
  end

  def self.down
    remove_column :locations, :is_hq
  end
end
