class AddTitleToChatSessions < ActiveRecord::Migration
  def self.up
    add_column        :chat_sessions,  :title, :string
  end

  def self.down
    remove_column     :chat_sessions,  :title
  end
end
