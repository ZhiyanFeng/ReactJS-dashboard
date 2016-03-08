class CreateCustomGroups < ActiveRecord::Migration
  def self.up
    create_table :custom_groups do |t|
    	t.string			:group_nickname,				null: false
    	t.integer			:owner_id,		 					null: false
    	t.integer			:location_id,		 				null: false
    	t.text				:members,            		null: false
    	t.boolean			:is_valid,            	default: true 
    	t.boolean			:is_public,            	default: false 

      t.timestamps
    end
  end

  def self.down
		drop_table :custom_groups
  end
end
