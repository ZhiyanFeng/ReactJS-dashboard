class CreateUserGroups < ActiveRecord::Migration
  def self.up
  	create_table :user_groups do |t|
  		t.integer   :org_id,              null: false
      t.integer   :owner_id,            null: false, default: 0
      t.integer   :member_count,        default: 0
      t.string    :group_name,          null: false
      t.string    :group_description,   null: false
      t.integer   :group_avatar_id
      t.boolean   :is_valid,            default: true 

      t.timestamps
    end
  end

  def self.down
  	drop_table :user_groups
  end
end
