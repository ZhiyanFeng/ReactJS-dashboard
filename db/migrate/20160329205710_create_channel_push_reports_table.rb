class CreateChannelPushReportsTable < ActiveRecord::Migration
  def up
    create_table    :channel_push_reports do |t|
      t.integer   :channel_id
      t.integer   :target_number
      t.integer   :attempted
      t.integer   :success
      t.integer   :failed_due_to_missing_id
      t.integer   :failed_due_to_other

      t.timestamps
    end
  end

  def down
    drop_table :channel_push_reports
  end
end
