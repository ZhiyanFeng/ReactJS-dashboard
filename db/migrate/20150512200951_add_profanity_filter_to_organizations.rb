class AddProfanityFilterToOrganizations < ActiveRecord::Migration
  def self.up
  	add_column 	:organizations, 	:profanity_filter,	 :boolean,	 default: false
  end

  def self.down
  	remove_column 	:organizations, 	:profanity_filter
  end
end
