class CreateUrls < ActiveRecord::Migration
  def self.up
  	create_table :urls do |t|
  		t.integer  :org_id,       null: false
      t.integer  :owner_id,     null: false
      t.string   :page_title
      t.string   :preview_url
      t.boolean  :is_valid,     default: true

      t.timestamps
    end
  end

  def self.down
  	drop_table :urls
  end
end
