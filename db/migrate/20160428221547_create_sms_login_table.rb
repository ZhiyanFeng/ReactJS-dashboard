class CreateSmsLoginTable < ActiveRecord::Migration
  def up
    create_table    :sms_logins do |t|
      t.integer   :user_id
      t.integer   :validation_code
      t.integer   :validation_entered
      t.boolean   :is_used
      t.boolean   :is_valid

      t.timestamps
    end
  end

  def down
    drop_table :sms_logins
  end
end
