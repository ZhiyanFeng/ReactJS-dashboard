class AddIsValidToNotificationsTable < ActiveRecord::Migration
  def self.up
    add_column        :notifications,  :is_valid, :boolean, :default => true
  end

  def self.down
    remove_column     :notifications,  :is_valid
  end
end
