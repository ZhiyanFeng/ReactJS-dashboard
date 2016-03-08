class CreateAdminClaimTable < ActiveRecord::Migration
  def up
    create_table    :admin_claims do |t|
      t.integer   :user_id
      t.integer   :ref_type
      t.integer   :ref_id
      t.string    :email
      t.string    :activation_code
      t.boolean   :is_active,           default: true
      t.boolean   :is_valid,            default: true

      t.timestamps
    end
  end

  def down
    drop_table :admin_claims
  end
end
