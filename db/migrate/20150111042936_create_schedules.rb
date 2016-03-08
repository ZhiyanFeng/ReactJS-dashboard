class CreateSchedules < ActiveRecord::Migration
  def self.up
  	create_table :schedules do |t|
  		t.string    :name,                  null: false
      t.integer   :org_id,                null: false
      t.timestamp :start_date
      t.timestamp :end_date
      t.integer   :admin_id
      t.boolean   :shift_trade,           default: true
      t.boolean   :trade_authorization,   default: true
      t.boolean   :is_valid,              default: true

      t.timestamps
    end
  end

  def self.down
  	drop_table :schedules
  end
end
