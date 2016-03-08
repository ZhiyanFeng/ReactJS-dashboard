class AddSafetyToCounters < ActiveRecord::Migration
  def self.up
    add_column :user_notification_counters, :safety_trainings, :integer, :default => 0
    add_column :user_notification_counters, :safety_quiz, :integer, :default => 0
  end

  def self.down
    remove_column :user_notification_counters, :safety_trainings
    remove_column :user_notification_counters, :safety_quiz
  end
end
