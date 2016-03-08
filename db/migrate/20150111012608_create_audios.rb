class CreateAudios < ActiveRecord::Migration
  def self.up
    create_table :audios do |t|
      t.integer			:org_id,			   			null: false
      t.integer			:owner_id,    				null: false
      t.integer			:audio_type,     			default: 0
      t.string	   	:audio_file_name,			null: false
      t.string	   	:audio_content_type,	null: false
      t.integer			:audio_file_size
      t.boolean			:is_valid,						null: false, default: true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :audios
  end
end
