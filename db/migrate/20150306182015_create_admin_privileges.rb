class CreateAdminPrivileges < ActiveRecord::Migration
	def self.up
  	create_table :admin_privileges do |t|
  		t.integer  :owner_id,       null: false
      t.integer  :org_id,         null: false
      t.integer  :location_id,    null: false
      t.integer  :master_key			
      t.integer  :parent_key      
      t.string   :key_hash
      t.boolean  :is_valid,       default: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :admin_privileges
  end
end