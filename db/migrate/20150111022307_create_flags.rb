class CreateFlags < ActiveRecord::Migration
  def self.up
    create_table :flags do |t|
    	t.integer  :owner_id, 			null: false
      t.integer  :source, 				null: false
      t.integer  :source_id, 			null: false
			t.boolean  :is_valid, 			default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :flags
  end
end
