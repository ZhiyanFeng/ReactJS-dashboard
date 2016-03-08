class CreateApiKeys < ActiveRecord::Migration
  def self.up
    create_table :api_keys do |t|
      t.string    :access_token,   	null: false, limit: 64
      t.string    :app_platform,    null: false, limit: 64
      t.string    :app_version,     null: false, limit: 64
      t.boolean   :is_valid,        null: false, default: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :api_keys
  end
end
