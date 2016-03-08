class CreateFileUploads < ActiveRecord::Migration
  def self.up
  	create_table :file_uploads do |t|
			t.integer  :org_id, 							null: false
      t.integer  :owner_id, 						null: false
      t.string   :key
      t.string   :file_location_url
      t.string   :upload_file_name
      t.string   :upload_content_type
      t.integer  :upload_file_size
      t.datetime :upload_updated_at
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :file_uploads
  end
end
