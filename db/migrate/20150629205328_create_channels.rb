class CreateChannels < ActiveRecord::Migration
  def up
    create_table :channels do |t|
    	t.string				:channel_type,        	    null: false
    	t.string				:channel_frequency,    	    null: false
    	t.string				:channel_profile_id
    	t.text   				:channel_latest_content
    	t.integer				:channel_content_count,			default: 0
    	t.integer				:owner_id, 									default: 0
    	t.integer				:member_count,							default: 0
    	t.boolean				:is_active,            			default: true
    	t.string				:become_active_when
      t.boolean       :allow_view,                default: true
      t.boolean       :allow_post,                default: true
      t.boolean       :allow_comment,             default: true
      t.boolean       :allow_like,                default: true
    	t.boolean				:is_public,            			default: true
			t.boolean				:is_valid,            			default: true

    	t.timestamps
    end
  end

  def down
    drop_table :channels
  end
end
