class CreateSubscription < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
    	t.integer				:user_id, 									        null: false
      t.integer       :channel_id,                        null: false
      t.integer       :subscription_content_count,        default: 0
    	t.string				:subscription_nickname
    	t.string				:subscription_my_alias
    	t.boolean				:subscription_stick_to_top,					default: false
    	t.boolean				:subscription_mute_notifications,		default: false
    	t.boolean				:subscription_display_nicknames,    default: true
      t.datetime      :subscription_last_synchronize,     default: nil
      t.integer       :allow_view,                        default: 0
      t.integer       :allow_post,                        default: 0
      t.integer       :allow_comment,                     default: 0
      t.integer       :allow_like,                        default: 0
    	t.boolean				:is_valid,            		    	    default: true

      t.timestamps
    end
  end

  def self.down
  	drop_table :subscriptions
  end
end
