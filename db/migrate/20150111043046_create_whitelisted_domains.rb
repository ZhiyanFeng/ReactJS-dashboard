class CreateWhitelistedDomains < ActiveRecord::Migration
  def self.up
  	create_table :whitelisted_domains do |t|
  		t.integer   :org_id,              null: false
      t.string    :domain,              null: false, limit: 50
      t.boolean   :is_valid,            default: true
      
      t.timestamps
    end
  end

  def self.down
  	drop_table :whitelisted_domains
  end
end
