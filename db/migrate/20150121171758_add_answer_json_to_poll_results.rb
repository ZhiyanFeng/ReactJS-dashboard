class AddAnswerJsonToPollResults < ActiveRecord::Migration
  def self.up
    add_column :poll_results, :answer_json, :text
  end

  def self.down
    remove_column :poll_results, :answer_json
  end
end
