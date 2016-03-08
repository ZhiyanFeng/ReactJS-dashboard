class AddFailAfterToRpushNotifications < ActiveRecord::Migration
  def self.up
    add_column :rpush_notifications, :fail_after, :timestamp, :null => true
  end

  def self.down
    remove_column :rpush_notifications, :fail_after
  end
end
