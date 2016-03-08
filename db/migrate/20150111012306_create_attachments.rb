class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.text    :json
    end
  end

  def self.down
    drop_table :attachments
  end
end
