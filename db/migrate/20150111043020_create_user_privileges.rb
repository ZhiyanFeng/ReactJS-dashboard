class CreateUserPrivileges < ActiveRecord::Migration
  def self.up
  	create_table :user_privileges do |t|
  		t.integer  :owner_id,       null: false
      t.integer  :org_id,         null: false
      t.boolean  :is_approved,    default: false
      t.boolean  :is_admin,       default: false
      t.boolean  :read_only,      default: false
      t.boolean  :is_root,        default: false
      t.boolean  :is_system,      default: false
      t.boolean  :is_valid,       default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :user_privileges
  end
end
