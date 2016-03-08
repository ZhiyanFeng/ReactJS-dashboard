class CreateUsers < ActiveRecord::Migration
  def self.up
  	create_table :users do |t|
  		t.string    :email,               null: false
      t.string    :number
      t.string    :password_hash
      t.string    :password_salt
      t.string    :first_name,          null: false
      t.string    :last_name,           null: false
      t.integer   :gender,              default: 0
      t.integer   :user_group,            default: 0
      t.integer   :location,            default: 0
      t.text      :status,              default: ""
      t.string    :chat_handle
      t.integer   :profile_id
      t.integer   :cover_id
      t.integer   :active_org,          default: 0
      t.integer   :push_count,          default: 0
      t.integer   :access_key_count,    default: 0
      t.boolean   :validated,           default: false
      t.string    :validation_hash,     null: false
      t.string    :auth_token
      t.string    :password_reset_token
      t.timestamp :password_reset_sent_at
      t.string    :phone_number
      t.boolean   :system_user,         default: false
      t.boolean   :is_valid,            default: true
      t.boolean   :is_visible,          default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :users
  end
end
