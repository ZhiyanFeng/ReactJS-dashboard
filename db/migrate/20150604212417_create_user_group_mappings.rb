class CreateUserGroupMappings < ActiveRecord::Migration
  def self.up
    create_table :user_group_mappings do |t|
    	t.integer			:user_id,		 					null: false
    	t.integer			:org_id,		 					null: false
    	t.integer			:group_id,						null: false
    	t.boolean			:is_valid,            default: true 

      t.timestamps
    end
  end

  def self.down
		drop_table :user_group_mappings
  end
end
