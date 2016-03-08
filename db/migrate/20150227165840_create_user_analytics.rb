class CreateUserAnalytics < ActiveRecord::Migration
  def self.up
    create_table :user_analytics do |t|
    	t.integer    :user_id,		 						 			null: false
    	t.integer    :action, 		:limit => 1, 			null: false
    	t.integer    :org_id
    	t.integer    :length, 		:limit => 3
    	t.integer    :source
    	t.integer    :source_id
    	t.string     :ip_address, :limit => 50

      t.timestamps
    end
  end

  def self.down
  	drop_table :user_analytics
  end
end
