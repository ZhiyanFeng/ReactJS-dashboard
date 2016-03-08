class CreateNotifications < ActiveRecord::Migration
  def self.up
  	create_table :notifications do |t|
      t.integer  :notify_id, 			null: false
      t.integer  :sender_id, 			null: false
      t.integer  :recipient_id
      t.integer  :org_id
      t.integer  :source, 				null: false
      t.integer  :source_id, 			null: false
      t.boolean  :viewed, 				default: false
      t.string   :event, 					null: false
      t.string   :message
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :notifications
  end
end
