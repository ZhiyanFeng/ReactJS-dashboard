class AddIsAdminToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column        :subscriptions,  :is_admin, :boolean, :default => false
  end

  def self.down
    remove_column     :subscriptions,  :is_admin
  end
end
