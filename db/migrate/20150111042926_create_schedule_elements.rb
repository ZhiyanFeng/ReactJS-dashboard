class CreateScheduleElements < ActiveRecord::Migration
  def self.up
  	create_table :schedule_elements do |t|
  		t.integer     :owner_id,        null: false
      t.integer     :schedule_id,     null: false
      t.string      :name,            null: false
      t.timestamp   :start_at
      t.timestamp   :end_at
      t.boolean     :is_valid,        default: true

      t.timestamps
    end
  end

  def self.down
  	drop_table :schedule_elements
  end
end
