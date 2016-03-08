class CreateSessionsTable < ActiveRecord::Migration
  def up
    create_table    :sessions do |t|
      t.integer   :user_id
      t.string    :ip_address
      t.string    :device
      t.string    :browser
      t.string    :version
      t.boolean   :is_active,           default: true
      t.boolean   :is_valid,            default: true

      t.timestamps
    end
  end

  def down
    drop_table :sessions
  end
end
