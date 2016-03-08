class AddIsCoffeeToUserPrivileges < ActiveRecord::Migration
  def self.up
  	add_column 			:user_privileges, 	:is_coffee, 		:boolean, :default => false
  	add_column 			:user_privileges, 	:is_invisible, 	:boolean, :default => false
  	add_column 			:subscriptions, 		:is_coffee, 		:boolean, :default => false
    add_column      :subscriptions,     :is_invisible,  :boolean, :default => false
  end

  def self.down
  	remove_column 	:user_privileges, 	:is_coffee
  	remove_column 	:user_privileges, 	:is_invisible
  	remove_column 	:subscriptions,   	:is_coffee
    remove_column   :subscriptions,     :is_invisible
  end
end
