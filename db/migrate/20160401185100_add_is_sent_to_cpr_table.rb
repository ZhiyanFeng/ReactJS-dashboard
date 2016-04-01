class AddIsSentToCprTable < ActiveRecord::Migration
  def self.up
    add_column        :channel_push_reports,  :is_sent, :boolean, :default => false
  end

  def self.down
    remove_column     :channel_push_reports,  :is_sent
  end
end
