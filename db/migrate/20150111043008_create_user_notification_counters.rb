class CreateUserNotificationCounters < ActiveRecord::Migration
  def self.up
  	create_table :user_notification_counters do |t|
  		t.integer   :user_id,          null: false
      t.integer   :org_id,           null: false
      t.timestamp :last_fetched
      t.integer   :newsfeeds,        default: 0
      t.integer   :announcements,    default: 0
      t.integer   :events,           default: 0
      t.integer   :trainings,        default: 0
      t.integer   :quizzes,          default: 0
      t.integer   :contacts,         default: 0
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :user_notification_counters
  end
end
