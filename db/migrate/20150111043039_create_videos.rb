class CreateVideos < ActiveRecord::Migration
  def self.up
  	create_table :videos do |t|
  		t.integer     :org_id,                  null: false
      t.integer     :owner_id,                null: false
      t.integer     :comments_count,          default: 0
      t.integer     :likes_count,             default: 0
      t.integer     :views_count,             default: 0
      t.integer     :video_type
      t.integer     :video_host
      t.string      :video_url
      t.string      :video_id
      t.string      :thumb_url
      t.integer     :video_duration,          default: 0
      t.string      :thumbnail_file_name
      t.string      :thumbnail_content_type
      t.integer     :thumbnail_file_size
      t.timestamp   :thumbnail_updated_at
      t.string      :video_file_name
      t.string      :video_content_type
      t.integer     :video_file_size
      t.timestamp   :video_updated_at
      t.string      :job_id
      t.string      :encoded_state
      t.string      :output_url
      t.integer     :duration_in_ms
      t.string      :aspect_ratio
      t.boolean     :is_valid,                default: true
    
      t.timestamps
    end
  end

  def self.down
  	drop_table :videos
  end
end
