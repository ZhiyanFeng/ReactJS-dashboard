class AddIsValidToSubscriptions < ActiveRecord::Migration
  def self.up
  	add_column 			:subscriptions, 	:is_active, 	:boolean, :default => true
  end

  def self.down
  	remove_column 	:subscriptions, 	:is_active
  end
end
